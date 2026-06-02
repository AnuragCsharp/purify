import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/storage_controller.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen>
    with AutomaticKeepAliveClientMixin {
  final _storage = Get.find<StorageController>();
  int _touchedIndex = -1;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Storage Analyzer'),
        leading: Get.previousRoute.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: Get.back)
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _storage.refresh,
          ),
        ],
      ),
      body: Obx(() {
        if (_storage.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.cyan),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildStorageBar(),
              const SizedBox(height: 20),
              _buildDonutChart(),
              const SizedBox(height: 20),
              _buildCategoryList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStorageBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.glassCard(
        gradient: LinearGradient(colors: [
          AppColors.cyan.withValues(alpha: 0.1),
          AppColors.card,
        ]),
        borderColor: AppColors.cyan.withValues(alpha: 0.25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Device Storage',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              Obx(() => Text(
                    '${(_storage.usedStorageMB.value / 1024).toStringAsFixed(1)} / ${(_storage.totalStorageMB.value / 1024).toStringAsFixed(0)} GB',
                    style: const TextStyle(
                        color: AppColors.cyan,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final pct = _storage.usedPercent.clamp(0.0, 1.0);
            return Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 1000),
                  widthFactor: pct,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: pct > 0.8
                            ? [AppColors.fireRed, AppColors.fireOrange]
                            : pct > 0.6
                                ? [AppColors.fireOrange, AppColors.fireYellow]
                                : [AppColors.blue, AppColors.cyan],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.4),
                          blurRadius: 8,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 10),
          Obx(() => Text(
                '${(_storage.freeStorageMB / 1024).toStringAsFixed(1)} GB free of ${(_storage.totalStorageMB.value / 1024).round()} GB',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              )),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildDonutChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.glassCard(),
      child: Column(
        children: [
          const Text('Usage Breakdown',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Obx(() {
              final sections = _storage.categories.map((cat) {
                final idx = _storage.categories.indexOf(cat);
                final isTouched = _touchedIndex == idx;
                return PieChartSectionData(
                  value: cat.sizeMB,
                  color: Color(cat.colorValue),
                  radius: isTouched ? 70 : 55,
                  title: isTouched ? cat.sizeLabel : '',
                  titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  badgeWidget: isTouched
                      ? Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(cat.colorValue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(cat.icon,
                              style: const TextStyle(fontSize: 14)),
                        )
                      : null,
                );
              }).toList();

              return PieChart(
                PieChartData(
                  sections: sections,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, resp) {
                      setState(() {
                        _touchedIndex =
                            resp?.touchedSection?.touchedSectionIndex ?? -1;
                      });
                    },
                  ),
                  centerSpaceRadius: 50,
                  sectionsSpace: 3,
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildCategoryList() {
    return Obx(() {
      final cats = _storage.categories;
      return Column(
        children: List.generate(cats.length, (i) {
          final cat = cats[i];
          final pct = _storage.usedStorageMB.value > 0
              ? cat.sizeMB / _storage.totalStorageMB.value
              : 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: AppColors.glassCard(radius: 14),
            child: Row(
              children: [
                Text(cat.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cat.name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          Text(cat.sizeLabel,
                              style: TextStyle(
                                  color: Color(cat.colorValue),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct.clamp(0.0, 1.0),
                          backgroundColor:
                              Color(cat.colorValue).withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(cat.colorValue)),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate(delay: Duration(milliseconds: 100 + i * 60))
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.2, end: 0);
        }),
      );
    });
  }
}
