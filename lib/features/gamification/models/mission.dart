class Mission {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int xpReward;
  bool isCompleted;
  int progress;
  final int total;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    this.isCompleted = false,
    this.progress = 0,
    required this.total,
  });

  double get progressPercent =>
      total > 0 ? (progress / total).clamp(0.0, 1.0) : 0;
}
