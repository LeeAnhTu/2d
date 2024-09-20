class ImageDetails {
  final String fileName;
  final String? alternateFileName;
  final double? alternateHeight;

  // Kích thước mặc định cho tất cả ảnh
  static const double defaultWidth = 80;
  static const double defaultHeight = 60;

  ImageDetails({
    required this.fileName,
    this.alternateFileName,
    this.alternateHeight,
  });

  factory ImageDetails.fromJson(Map<String, dynamic> json) {
    return ImageDetails(
      fileName: json['fileName'],
      alternateFileName: json['alternateFileName'],
      alternateHeight: json['alternateHeight'] != null
          ? json['alternateHeight'].toDouble()
          : null,
    );
  }
}
