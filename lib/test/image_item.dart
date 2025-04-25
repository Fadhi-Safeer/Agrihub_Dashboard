class ImageItem {
  final String filename;
  final String url;

  ImageItem({required this.filename, required this.url});

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      filename: json['filename'],
      url: json['url'],
    );
  }
}
