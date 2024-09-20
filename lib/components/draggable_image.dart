import 'package:flutter/material.dart'; // Đảm bảo chỉ cần import này

class DraggableImage {
  String fileName;
  Offset position;
  double width;
  double height;

  DraggableImage({
    required this.fileName,
    required this.position,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'position': {'dx': position.dx, 'dy': position.dy},
    'width': width,
    'height': height,
  };

  factory DraggableImage.fromJson(Map<String, dynamic> json) {
    return DraggableImage(
      fileName: json['fileName'],
      position: Offset(json['position']['dx'], json['position']['dy']),
      width: json['width'],
      height: json['height'],
    );
  }

}