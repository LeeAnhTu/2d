import 'package:flutter/material.dart'; // Đảm bảo chỉ cần import này

class DraggableImage {
  final String fileName; // Đường dẫn tới ảnh
  Offset position; // Offset được định nghĩa trong 'flutter/material.dart'
  final double width;
  final double height;

  DraggableImage({
    required this.fileName, // Thêm thuộc tính fileName
    required this.position,
    required this.width,
    required this.height,
  });
}
