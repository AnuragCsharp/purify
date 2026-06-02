import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/device/controllers/device_controller.dart';
import 'features/gamification/controllers/gamification_controller.dart';
import 'features/cleaner/controllers/cleaner_controller.dart';
import 'features/ram/controllers/ram_controller.dart';
import 'features/storage/controllers/storage_controller.dart';
import 'features/home/controllers/home_controller.dart';

class CleanDroidApp extends StatelessWidget {
  const CleanDroidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CleanDroid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialBinding: _AppBindings(),
      home: const SplashScreen(),
    );
  }
}

class _AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(DeviceController(), permanent: true);
    Get.put(GamificationController(), permanent: true);
    Get.put(CleanerController(), permanent: true);
    Get.put(RamController(), permanent: true);
    Get.put(StorageController(), permanent: true);
    Get.put(HomeController(), permanent: true);
  }
}
