class JunkItem {
  final String name;
  final String icon;
  final double sizeMB;
  final String category;

  JunkItem({
    required this.name,
    required this.icon,
    required this.sizeMB,
    required this.category,
  });

  String get sizeLabel {
    if (sizeMB >= 1024) return '${(sizeMB / 1024).toStringAsFixed(1)} GB';
    if (sizeMB >= 1) return '${sizeMB.toStringAsFixed(0)} MB';
    return '${(sizeMB * 1024).toStringAsFixed(0)} KB';
  }
}
