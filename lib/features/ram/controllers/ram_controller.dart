import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../device/controllers/device_controller.dart';

class ProcessInfo {
  final String packageName;
  final String displayName;
  final String icon;
  int ramMB;
  bool killed;

  ProcessInfo({
    required this.packageName,
    required this.displayName,
    required this.icon,
    required this.ramMB,
    this.killed = false,
  });
}

class RamController extends GetxController {
  static const _channel = MethodChannel('com.metavisionrs.clean_droid/system');

  final totalRamMB = 4096.obs;
  final usedRamMB = 2600.obs;
  final isBoosting = false.obs;
  final boostedMB = 0.obs;
  final totalBoostedCount = 0.obs;
  final processes = <ProcessInfo>[].obs;
  final isLoadingProcesses = false.obs;

  int get freeRamMB => totalRamMB.value - usedRamMB.value;
  double get usedPercent =>
      totalRamMB.value > 0 ? usedRamMB.value / totalRamMB.value : 0;

  @override
  void onInit() {
    super.onInit();
    _refreshRam();
    loadProcesses();
    _loadStats();
  }

  Future<void> _refreshRam() async {
    try {
      final result = await _channel.invokeMethod('getRamInfo') as Map;
      totalRamMB.value = result['totalMB'] as int;
      usedRamMB.value = (result['totalMB'] as int) - (result['availableMB'] as int);
    } catch (_) {
      try {
        final device = Get.find<DeviceController>();
        totalRamMB.value = device.totalRamMB.value;
        usedRamMB.value = device.usedRamMB.value;
      } catch (_) {}
    }
  }

  Future<void> loadProcesses() async {
    isLoadingProcesses.value = true;
    try {
      final raw = await _channel.invokeMethod('getRunningProcesses') as List;
      final list = raw
          .map((e) => e as Map)
          .where((e) => (e['rssKB'] as int? ?? 0) > 512) // skip tiny system processes
          .map((e) {
            final pkg = e['name'] as String;
            final rssKb = e['rssKB'] as int? ?? 0;
            return ProcessInfo(
              packageName: pkg,
              displayName: _formatName(pkg),
              icon: _iconFor(pkg),
              ramMB: (rssKb / 1024).round().clamp(1, 9999),
            );
          })
          .toList()
        ..sort((a, b) => b.ramMB.compareTo(a.ramMB)); // heaviest first

      processes.value = list.take(12).toList(); // show top 12
    } catch (_) {
      processes.value = [];
    }
    isLoadingProcesses.value = false;
  }

  @override
  Future<void> refresh() => _refreshRam();

  Future<void> boost() async {
    if (isBoosting.value) return;
    isBoosting.value = true;
    boostedMB.value = 0;

    // Collect packages to kill (all loaded background processes)
    final packages = processes.map((p) => p.packageName).toList();

    // Animate killing each process in the list
    for (final p in List.of(processes)) {
      await Future.delayed(const Duration(milliseconds: 180));
      p.killed = true;
      boostedMB.value += p.ramMB;
      processes.refresh();
    }

    // Actually kill them via native channel and get real freed MB
    try {
      final result = await _channel.invokeMethod(
        'killBackgroundProcesses',
        {'packages': packages},
      ) as Map;

      final realFreedMB = result['freedMB'] as int? ?? 0;
      final newAvailMB = result['availableMB'] as int? ?? 0;
      final totalMB = result['totalMB'] as int? ?? totalRamMB.value;

      // Update RAM stats with real post-kill values
      totalRamMB.value = totalMB;
      if (newAvailMB > 0) {
        usedRamMB.value = totalMB - newAvailMB;
      }
      // Show the real freed amount if it's meaningful, else keep animated total
      if (realFreedMB > 10) {
        boostedMB.value = realFreedMB;
      }
    } catch (_) {
      // Fallback: reflect estimated freed in RAM gauge
      final est = (usedRamMB.value * 0.18).round();
      usedRamMB.value = (usedRamMB.value - est).clamp(
          (totalRamMB.value * 0.20).round(), totalRamMB.value);
    }

    totalBoostedCount.value++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('boostCount', totalBoostedCount.value);

    await Future.delayed(const Duration(milliseconds: 400));
    isBoosting.value = false;

    // Reload fresh real process list after 1.5s
    await Future.delayed(const Duration(milliseconds: 1500));
    await loadProcesses();
    await _refreshRam();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    totalBoostedCount.value = prefs.getInt('boostCount') ?? 0;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatName(String packageName) {
    // "com.google.android.youtube" → "YouTube"
    // "com.facebook.katana" → "Facebook"
    final known = {
      'com.google.android.youtube': 'YouTube',
      'com.google.android.gm': 'Gmail',
      'com.google.android.apps.maps': 'Google Maps',
      'com.google.android.googlequicksearchbox': 'Google Search',
      'com.google.android.apps.photos': 'Google Photos',
      'com.google.android.music': 'Google Music',
      'com.google.android.videos': 'Google Videos',
      'com.google.android.calendar': 'Calendar',
      'com.google.android.keep': 'Google Keep',
      'com.google.android.apps.docs': 'Google Docs',
      'com.google.android.apps.messaging': 'Messages',
      'com.facebook.katana': 'Facebook',
      'com.facebook.orca': 'Messenger',
      'com.instagram.android': 'Instagram',
      'com.whatsapp': 'WhatsApp',
      'com.twitter.android': 'Twitter / X',
      'com.snapchat.android': 'Snapchat',
      'com.spotify.music': 'Spotify',
      'com.netflix.mediaclient': 'Netflix',
      'com.amazon.mShop.android.shopping': 'Amazon',
      'com.samsung.android.messaging': 'Samsung Messages',
      'com.samsung.android.email.provider': 'Samsung Email',
      'com.samsung.android.contacts': 'Contacts',
      'com.samsung.android.dialer': 'Phone',
      'com.sec.android.app.camera': 'Camera',
      'com.microsoft.teams': 'Teams',
      'com.microsoft.launcher': 'MS Launcher',
      'org.telegram.messenger': 'Telegram',
      'com.zhiliaoapp.musically': 'TikTok',
      'com.ss.android.ugc.trill': 'TikTok',
    };
    if (known.containsKey(packageName)) return known[packageName]!;
    // Generic formatting: take last segment, capitalise
    final parts = packageName.split('.');
    final last = parts.last.replaceAll('_', ' ');
    return last[0].toUpperCase() + last.substring(1);
  }

  String _iconFor(String pkg) {
    if (pkg.contains('youtube')) return '▶️';
    if (pkg.contains('chrome') || pkg.contains('browser')) return '🌐';
    if (pkg.contains('instagram')) return '📸';
    if (pkg.contains('whatsapp')) return '💬';
    if (pkg.contains('facebook') || pkg.contains('fb')) return '👤';
    if (pkg.contains('twitter') || pkg.contains('tbird')) return '🐦';
    if (pkg.contains('spotify') || pkg.contains('music') || pkg.contains('audio')) return '🎵';
    if (pkg.contains('map') || pkg.contains('navigation')) return '🗺️';
    if (pkg.contains('mail') || pkg.contains('email') || pkg.contains('gmail')) return '📧';
    if (pkg.contains('camera') || pkg.contains('photo') || pkg.contains('gallery')) return '📷';
    if (pkg.contains('netflix') || pkg.contains('video') || pkg.contains('movie')) return '🎬';
    if (pkg.contains('telegram') || pkg.contains('messenger') || pkg.contains('chat')) return '💬';
    if (pkg.contains('tiktok') || pkg.contains('musically')) return '🎵';
    if (pkg.contains('snapchat')) return '👻';
    if (pkg.contains('game') || pkg.contains('play')) return '🎮';
    if (pkg.contains('amazon') || pkg.contains('shop')) return '🛒';
    if (pkg.contains('samsung')) return '📱';
    if (pkg.contains('google')) return '🔍';
    if (pkg.contains('microsoft') || pkg.contains('teams')) return '💼';
    return '⚙️';
  }
}
