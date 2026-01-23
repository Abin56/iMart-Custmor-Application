import 'package:flutter/material.dart';

/// Custom clipper for discount/offer badge with arrow shape
/// Creates a pentagonal badge with a pointed bottom (arrow effect)
///
/// Used for discount badges on product cards
class BadgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      // Top left corner
      ..moveTo(0, 0)
      // Top right corner
      ..lineTo(size.width, 0)
      // Right edge down to 75% height
      ..lineTo(size.width, size.height * 0.75)
      // Diagonal to center bottom (arrow point)
      ..lineTo(size.width * 0.5, size.height)
      // Diagonal back to left edge at 75% height
      ..lineTo(0, size.height * 0.75)
      // Left edge back up
      ..lineTo(0, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
