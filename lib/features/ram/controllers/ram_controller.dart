import 'dart:math';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../device/controllers/device_controller.dart';

class ProcessInfo {
  final String name;
  final String icon;
  int ramMB;
  ProcessInfo({required this.name, required this.icon, required this.ramMB});
}

class RamController extends GetxController {
  static const _channel = MethodChannel('com.metavisionrs.clean_droid/system');

  final totalRamMB = 4096.obs;
  final usedRamMB = 2600.obs;
  final isBoosting = false.obs;
  final boostedMB = 0.obs;
  final totalBoostedCount = 0.obs;
  final processes = <ProcessInfo>[].obs;

  int get freeRamMB => totalRamMB.value - usedRamMB.value;
  double get usedPercent =>
      totalRamMB.value > 0 ? usedRamMB.value / totalRamMB.value : 0;

  @override
  void onInit() {
    super.onInit();
    _syncWithDevice();
    _loadProcesses();
    _loadStats();
  }

  void _syncWithDevice() {
    try {
      final device = Get.find<DeviceController>();
      totalRamMB.value = device.totalRamMB.value;
      usedRamMB.value = device.usedRamMB.value;
    } catch (_) {}
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    totalBoostedCount.value = prefs.getInt('boostCount') ?? 0;
  }

  void _loadProcesses() {
    final rng = Random();
    processes.value = [
      ProcessInfo(name: 'Chrome Browser', icon: '🌐', ramMB: 180 + rng.nextInt(120)),
      ProcessInfo(name: 'Social Media', icon: '📱', ramMB: 120 + rng.nextInt(80)),
      ProcessInfo(name: 'Maps', icon: '🗺️', ramMB: 90 + rng.nextInt(60)),
      ProcessInfo(name: 'Email Client', icon: '📧', ramMB: 60 + rng.nextInt(40)),
      ProcessInfo(name: 'Music Player', icon: '🎵', ramMB: 40 + rng.nextInt(30)),
      ProcessInfo(name: 'Camera', icon: '📷', ramMB: 80 + rng.nextInt(50)),
      ProcessInfo(name: 'Background Sync', icon: '🔄', ramMB: 30 + rng.nextInt(20)),
    ];
  }

  Future<void> refresh() async {
    try {
      final result =
          await _channel.invokeMethod('getRamInfo') as Map;
      totalRamMB.value = result['totalMB'] as int;
      usedRamMB.value =
          (result['totalMB'] as int) - (result['availableMB'] as int);
    } catch (_) {
      _syncWithDevice();
    }
  }

  Future<void> boost() async {
    if (isBoosting.value) return;
    isBoosting.value = true;
    boostedMB.value = 0;

    // Simulate freeing RAM from processes
    final rng = Random();
    int freed = 0;
    for (final p in processes) {
      await Future.delayed(const Duration(milliseconds: 200));
      final release = (p.ramMB * (0.4 + rng.nextDouble() * 0.3)).round();
      freed += release;
      p.ramMB = p.ramMB - release;
      boostedMB.value = freed;
      processes.refresh();
    }

    // Update actual RAM
    final newUsed = (usedRamMB.value - freed).clamp(
        (totalRamMB.value * 0.25).round(), totalRamMB.value);
    usedRamMB.value = newUsed;
    boostedMB.value = freed;

    totalBoostedCount.value++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('boostCount', totalBoostedCount.value);

    await Future.delayed(const Duration(milliseconds: 500));
    isBoosting.value = false;

    // Reload processes after boost
    await Future.delayed(const Duration(seconds: 2));
    _loadProcesses();
  }
}
