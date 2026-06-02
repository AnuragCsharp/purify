import 'dart:math';
import 'package:get/get.dart';

class StorageCategory {
  final String name;
  final String icon;
  final double sizeMB;
  final int colorValue;

  StorageCategory({
    required this.name,
    required this.icon,
    required this.sizeMB,
    required this.colorValue,
  });

  String get sizeLabel {
    if (sizeMB >= 1024) return '${(sizeMB / 1024).toStringAsFixed(1)} GB';
    return '${sizeMB.toStringAsFixed(0)} MB';
  }
}

class StorageController extends GetxController {
  final totalStorageMB = 64000.0.obs;
  final usedStorageMB = 0.0.obs;
  final categories = <StorageCategory>[].obs;
  final isLoading = true.obs;

  double get freeStorageMB => totalStorageMB.value - usedStorageMB.value;
  double get usedPercent =>
      totalStorageMB.value > 0 ? usedStorageMB.value / totalStorageMB.value : 0;

  @override
  void onInit() {
    super.onInit();
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    final rng = Random();
    final appsMB = 8000.0 + rng.nextDouble() * 4000;
    final photosMB = 5000.0 + rng.nextDouble() * 8000;
    final videosMB = 3000.0 + rng.nextDouble() * 6000;
    final musicMB = 500.0 + rng.nextDouble() * 2000;
    final otherMB = 2000.0 + rng.nextDouble() * 3000;

    categories.value = [
      StorageCategory(name: 'Apps', icon: '📱', sizeMB: appsMB, colorValue: 0xFF0072FF),
      StorageCategory(name: 'Photos', icon: '🖼️', sizeMB: photosMB, colorValue: 0xFF00E676),
      StorageCategory(name: 'Videos', icon: '🎬', sizeMB: videosMB, colorValue: 0xFF7B2FFF),
      StorageCategory(name: 'Music', icon: '🎵', sizeMB: musicMB, colorValue: 0xFFFF9800),
      StorageCategory(name: 'Other', icon: '📁', sizeMB: otherMB, colorValue: 0xFF9DB2CE),
    ];

    usedStorageMB.value = categories.fold(0.0, (s, c) => s + c.sizeMB);
    isLoading.value = false;
  }

  @override
  Future<void> refresh() => _loadStorage();
}
