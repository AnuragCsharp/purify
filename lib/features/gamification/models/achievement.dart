class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int xpReward;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    this.isUnlocked = false,
    this.unlockedAt,
  });
}
