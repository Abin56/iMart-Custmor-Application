import 'package:flutter/material.dart';

/// Custom clipper for green container with smooth arc curve at bottom center
/// Creates a smooth circular wave where category icons sit
class GreenCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;

    return Path()
      // Start from top-left
      ..moveTo(0, 0)
      // Top edge
      ..lineTo(width, 0)
      // Right edge down to curve start
      ..lineTo(width, height - 50)
      // Smooth wide wave curve at bottom - single continuous bezier
      ..quadraticBezierTo(
        width / 2,
        height + 50, // Control point at center - creates gentle downward curve
        0,
        height - 50, // End point at left side
      )
      // Left edge up
      ..lineTo(0, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Custom clipper for white container with smooth upward arc at top center
/// Mirrors the green container's arc to create perfect nesting
class WhiteCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;

    return Path()
      // Start from bottom-left
      ..moveTo(0, height)
      // Left edge up to curve start
      ..lineTo(0, 50)
      // Smooth wide wave curve at top - single continuous bezier (mirrors green)
      ..quadraticBezierTo(
        width / 2,
        -60, // Control point at center - creates gentle upward curve
        width,
        50, // End point at right side
      )
      // Right edge down
      ..lineTo(width, height)
      // Bottom edge
      ..lineTo(0, height)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
