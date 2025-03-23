// Custom Clipper for Wave Effect
import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60); // Start from bottom left
    path.quadraticBezierTo(
        size.width / 4, size.height, size.width / 2, size.height - 60);
    path.quadraticBezierTo(
        size.width * 3 / 4, size.height - 120, size.width, size.height - 60);
    path.lineTo(size.width, 0); // Top right
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom Clipper for Wave Effect at the Bottom
class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0); // Start from top-left
    path.lineTo(0, size.height * 0.7); // Move to 70% height
    path.quadraticBezierTo(
        size.width / 4, size.height * 0.9, size.width / 2, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 3 / 4, size.height * 0.7, size.width, size.height * 0.8);
    path.lineTo(size.width, 0); // Move back to top-right
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
