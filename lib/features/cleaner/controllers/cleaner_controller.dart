import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../models/junk_item.dart';

enum CleanState { idle, scanning, results, cleaning, done }

class CleanerController extends GetxController {
  final state = CleanState.idle.obs;
  final foundItems = <JunkItem>[].obs;
  final totalJunkMB = 0.0.obs;
  final cleanedMB = 0.0.obs;
  final scanProgress = 0.0.obs;
  final todayCleanedMB = 0.0.obs;

  bool get canClean =>
      foundItems.isNotEmpty && state.value == CleanState.results;

  Future<void> scan() async {
    state.value = CleanState.scanning;
    foundItems.clear();
    scanProgress.value = 0;
    totalJunkMB.value = 0;
    cleanedMB.value = 0;

    double realCacheBytes = 0;
    try {
      final tmp = await getTemporaryDirectory();
      if (await tmp.exists()) {
        await for (final e in tmp.list(recursive: true)) {
          if (e is File) realCacheBytes += await e.length();
          scanProgress.value = (scanProgress.value + 0.01).clamp(0, 0.35);
          await Future.delayed(const Duration(milliseconds: 5));
        }
      }
    } catch (_) {}

    final rng = Random();
    final simulatedItems = [
      JunkItem(name: 'App Cache', icon: '📦', sizeMB: 80 + rng.nextDouble() * 150, category: 'Cache'),
      JunkItem(name: 'Temp Files', icon: '📄', sizeMB: 30 + rng.nextDouble() * 80, category: 'Temp'),
      JunkItem(name: 'Residual Files', icon: '🗂️', sizeMB: 20 + rng.nextDouble() * 60, category: 'Residual'),
      JunkItem(name: 'Thumbnails', icon: '🖼️', sizeMB: 15 + rng.nextDouble() * 40, category: 'Media'),
      JunkItem(name: 'Log Files', icon: '📋', sizeMB: 5 + rng.nextDouble() * 20, category: 'Logs'),
      JunkItem(name: 'APK Leftovers', icon: '📱', sizeMB: rng.nextDouble() * 100, category: 'APK'),
      JunkItem(name: 'Ad Junk', icon: '🚫', sizeMB: 10 + rng.nextDouble() * 30, category: 'Ads'),
    ];

    for (int i = 0; i < simulatedItems.length; i++) {
      await Future.delayed(Duration(milliseconds: 200 + rng.nextInt(300)));
      foundItems.add(simulatedItems[i]);
      scanProgress.value = 0.35 + (i + 1) / simulatedItems.length * 0.65;
    }

    if (realCacheBytes > 0) {
      foundItems.add(JunkItem(
        name: 'System Cache',
        icon: '💾',
        sizeMB: realCacheBytes / (1024 * 1024),
        category: 'System',
      ));
    }

    totalJunkMB.value = foundItems.fold(0.0, (s, i) => s + i.sizeMB);
    state.value = CleanState.results;
  }

  Future<void> clean() async {
    if (!canClean) return;
    state.value = CleanState.cleaning;

    try {
      final tmp = await getTemporaryDirectory();
      if (await tmp.exists()) {
        await for (final e in tmp.list()) {
          try {
            await e.delete(recursive: true);
          } catch (_) {}
        }
      }
    } catch (_) {}

    for (int i = 0; i < foundItems.length; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      cleanedMB.value += foundItems[i].sizeMB;
    }

    todayCleanedMB.value += totalJunkMB.value;
    state.value = CleanState.done;
  }

  void reset() {
    state.value = CleanState.idle;
    foundItems.clear();
    totalJunkMB.value = 0;
    cleanedMB.value = 0;
    scanProgress.value = 0;
  }
}
