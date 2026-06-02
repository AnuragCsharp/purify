import 'package:get/get.dart';
import '../../device/controllers/device_controller.dart';
import '../../gamification/controllers/gamification_controller.dart';
import '../../cleaner/controllers/cleaner_controller.dart';
import '../../ram/controllers/ram_controller.dart';

class HomeController extends GetxController {
  final isQuickCleaning = false.obs;
  final quickCleanResult = ''.obs;

  DeviceController get _device => Get.find<DeviceController>();
  GamificationController get _gami => Get.find<GamificationController>();

  double get performanceScore {
    final ramScore = (1 - _device.ramUsedPercent) * 40;
    final storageScore = (1 - _device.storageUsedPercent) * 40;
    final batteryScore = _device.batteryLevel.value / 100 * 20;
    return (ramScore + storageScore + batteryScore).clamp(0.0, 100.0);
  }

  String get performanceLabel {
    final score = performanceScore;
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  Future<void> quickClean() async {
    if (isQuickCleaning.value) return;
    isQuickCleaning.value = true;

    final cleaner = Get.find<CleanerController>();
    final ram = Get.find<RamController>();

    await cleaner.scan();
    await cleaner.clean();
    await ram.boost();
    await _gami.recordClean(cleaner.cleanedMB.value.round());
    await _gami.recordBoost();

    quickCleanResult.value =
        '${cleaner.cleanedMB.value.toStringAsFixed(0)} MB freed';
    isQuickCleaning.value = false;
    cleaner.reset();
    _device.refreshAll();
  }
}
