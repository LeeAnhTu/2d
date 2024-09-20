import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;

  const CustomIconButton({
    required this.icon,
    required this.onPressed,
    this.color = Colors.green, // Mặc định là màu xanh
    this.size = 40.0, // Kích thước mặc định
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size, color: color),
      onPressed: onPressed,
    );
  }
}
