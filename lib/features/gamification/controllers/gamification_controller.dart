import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/mission.dart';

class GamificationController extends GetxController {
  final xp = 0.obs;
  final level = 1.obs;
  final streak = 0.obs;
  final totalCleanedMB = 0.obs;
  final totalBoosted = 0.obs;
  final lastCleanDate = Rx<DateTime?>(null);
  final achievements = <Achievement>[].obs;
  final dailyMissions = <Mission>[].obs;
  final showLevelUp = false.obs;
  final unlockedAchievement = Rx<Achievement?>(null);

  static const List<int> _thresholds = [
    0, 100, 300, 600, 1000, 1500, 2200, 3000, 4000, 5500, 7500, 10000
  ];
  static const List<String> _titles = [
    'Novice', 'Cache Buster', 'RAM Rookie', 'Speed Demon',
    'Purifier', 'System Guardian', 'Memory Master',
    'Flame Warrior', 'Fire Lord', 'CleanDroid Legend',
    'Grand Purifier', 'Inferno God',
  ];

  String get levelTitle =>
      level.value <= _titles.length ? _titles[level.value - 1] : 'Master';

  int get xpForNext =>
      level.value < _thresholds.length ? _thresholds[level.value] : 99999;

  int get xpForCurrent =>
      (level.value - 1) < _thresholds.length ? _thresholds[level.value - 1] : 0;

  double get levelProgress {
    final cur = xp.value - xpForCurrent;
    final req = xpForNext - xpForCurrent;
    return req > 0 ? (cur / req).clamp(0.0, 1.0) : 1.0;
  }

  int get flameCount {
    if (level.value >= 9) return 5;
    if (level.value >= 7) return 4;
    if (level.value >= 5) return 3;
    if (level.value >= 3) return 2;
    return 1;
  }

  int get performanceScore {
    final cleanScore = (totalCleanedMB.value / 100).clamp(0, 30).toInt();
    final levelScore = (level.value * 5).clamp(0, 40);
    final streakScore = (streak.value * 3).clamp(0, 30);
    return (cleanScore + levelScore + streakScore).clamp(0, 100);
  }

  @override
  void onInit() {
    super.onInit();
    _loadAchievements();
    _loadDailyMissions();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    xp.value = prefs.getInt('xp') ?? 0;
    streak.value = prefs.getInt('streak') ?? 0;
    totalCleanedMB.value = prefs.getInt('totalCleaned') ?? 0;
    totalBoosted.value = prefs.getInt('totalBoosted') ?? 0;
    _recalcLevel();
    final lastStr = prefs.getString('lastClean');
    if (lastStr != null) {
      final last = DateTime.parse(lastStr);
      lastCleanDate.value = last;
      final diff = DateTime.now().difference(last).inDays;
      if (diff > 1) {
        streak.value = 0;
        prefs.setInt('streak', 0);
      }
    }
  }

  Future<void> addXP(int amount) async {
    xp.value += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('xp', xp.value);
    final old = level.value;
    _recalcLevel();
    if (level.value > old) {
      showLevelUp.value = true;
      Future.delayed(const Duration(seconds: 3), () => showLevelUp.value = false);
    }
  }

  void _recalcLevel() {
    for (int i = _thresholds.length - 1; i >= 0; i--) {
      if (xp.value >= _thresholds[i]) {
        level.value = i + 1;
        return;
      }
    }
    level.value = 1;
  }

  Future<void> recordClean(int mb) async {
    totalCleanedMB.value += mb;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalCleaned', totalCleanedMB.value);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = lastCleanDate.value;
    if (last == null ||
        DateTime(last.year, last.month, last.day) != today) {
      if (last != null &&
          today.difference(DateTime(last.year, last.month, last.day)).inDays ==
              1) {
        streak.value++;
      } else if (last == null) {
        streak.value = 1;
      }
      await prefs.setInt('streak', streak.value);
    }
    lastCleanDate.value = now;
    await prefs.setString('lastClean', now.toIso8601String());

    _checkAchievements();
    _updateMission('clean_once');
    if (mb >= 500) _updateMission('clean_500mb');
    await addXP(50 + (mb ~/ 10).clamp(0, 200));
  }

  Future<void> recordBoost() async {
    totalBoosted.value++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalBoosted', totalBoosted.value);
    _checkAchievements();
    _updateMission('boost_once');
    await addXP(30);
  }

  void _checkAchievements() {
    for (final a in achievements) {
      if (a.isUnlocked) continue;
      bool unlock = false;
      switch (a.id) {
        case 'first_clean':
          unlock = totalCleanedMB.value > 0;
          break;
        case 'clean_1gb':
          unlock = totalCleanedMB.value >= 1024;
          break;
        case 'boost_5':
          unlock = totalBoosted.value >= 5;
          break;
        case 'streak_7':
          unlock = streak.value >= 7;
          break;
        case 'level_5':
          unlock = level.value >= 5;
          break;
        case 'level_10':
          unlock = level.value >= 10;
          break;
        case 'inferno':
          unlock = level.value >= 8;
          break;
      }
      if (unlock) {
        a.isUnlocked = true;
        a.unlockedAt = DateTime.now();
        unlockedAchievement.value = a;
        achievements.refresh();
        addXP(a.xpReward);
        Future.delayed(
            const Duration(seconds: 4), () => unlockedAchievement.value = null);
      }
    }
  }

  void _updateMission(String id) {
    final m = dailyMissions.firstWhereOrNull((m) => m.id == id);
    if (m != null && !m.isCompleted) {
      m.progress = (m.progress + 1).clamp(0, m.total);
      if (m.progress >= m.total) {
        m.isCompleted = true;
        addXP(m.xpReward);
      }
      dailyMissions.refresh();
    }
  }

  void _loadAchievements() {
    achievements.value = [
      Achievement(id: 'first_clean', title: 'First Flame', description: 'Complete first clean', icon: '🔥', xpReward: 100),
      Achievement(id: 'clean_1gb', title: 'Storage King', description: 'Free 1GB of storage', icon: '👑', xpReward: 300),
      Achievement(id: 'boost_5', title: 'Speed Racer', description: 'Boost RAM 5 times', icon: '⚡', xpReward: 150),
      Achievement(id: 'streak_7', title: 'Streak Master', description: 'Clean 7 days straight', icon: '🏆', xpReward: 500),
      Achievement(id: 'level_5', title: 'Purifier', description: 'Reach level 5', icon: '⭐', xpReward: 200),
      Achievement(id: 'level_10', title: 'Fire Lord', description: 'Reach level 10', icon: '🌟', xpReward: 1000),
      Achievement(id: 'inferno', title: 'Inferno', description: 'Reach level 8', icon: '🔱', xpReward: 600),
    ];
  }

  void _loadDailyMissions() {
    dailyMissions.value = [
      Mission(id: 'clean_once', title: 'Daily Cleanse', description: 'Clean junk files once', icon: '🧹', xpReward: 50, total: 1),
      Mission(id: 'boost_once', title: 'Power Surge', description: 'Boost RAM once', icon: '⚡', xpReward: 30, total: 1),
      Mission(id: 'clean_500mb', title: 'Big Burn', description: 'Free 500MB in one clean', icon: '🔥', xpReward: 100, total: 1),
    ];
  }
}
