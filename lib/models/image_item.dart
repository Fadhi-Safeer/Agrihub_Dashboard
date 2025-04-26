class ImageItem {
  final String url;
  final String description;

  ImageItem({
    required this.url,
    required this.description,
  });

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      url: json['url'],
      description: json['description'],
    );
  }
}
