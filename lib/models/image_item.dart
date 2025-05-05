class ImageItem {
  final String url;
  final String health;
  final String growth;
  final String disease;

  ImageItem({
    required this.url,
    required this.health,
    required this.growth,
    required this.disease,
  });

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      url: json['url'],
      health: json['health'] ?? 'Unknown',
      growth: json['growth'] ?? 'Unknown',
      disease: json['disease'] ?? 'Unknown',
    );
  }
}
