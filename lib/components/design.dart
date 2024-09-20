import 'dart:convert';
import 'package:flutter/material.dart';
import 'draggable_image.dart';

class Design {
  final String name;
  final List<DraggableImage> draggableImages;
  final double width;
  final double height;
  final String roomType;

  Design({
    required this.name,
    required this.draggableImages,
    required this.width,
    required this.height,
    required this.roomType,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'draggableImages': draggableImages.map((image) => image.toJson()).toList(),
    'width': width,
    'height': height,
    'roomType': roomType,
  };

  factory Design.fromJson(Map<String, dynamic> json) {
    return Design(
      name: json['name'],
      draggableImages: (json['draggableImages'] as List)
          .map((imageJson) => DraggableImage.fromJson(imageJson))
          .toList(),
      width: json['width'],
      height: json['height'],
      roomType: json['roomType'],
    );
  }
}