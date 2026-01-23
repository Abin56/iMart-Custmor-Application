import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';
import 'category_item.dart';

/// Category carousel with rotary dial animation
/// Swipeable carousel with smooth curve following
class CategoryCarousel extends StatefulWidget {
  const CategoryCarousel({
    required this.categories,
    this.onCategoryTap,
    super.key,
  });

  final List<Category> categories;
  final ValueChanged<Category>? onCategoryTap;

  @override
  State<CategoryCarousel> createState() => _CategoryCarouselState();
}

class _CategoryCarouselState extends State<CategoryCarousel>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  double _currentPage = 0.0;
  late AnimationController _rotationController;
  bool _autoRotating = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.25);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });

    // Auto-rotation animation controller
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    // Start auto-rotation animation
    _startAutoRotation();
  }

  Future<void> _startAutoRotation() async {
    // Wait a bit before starting
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted || !_autoRotating) return;

    // Check if position is ready
    if (!_pageController.hasClients ||
        !_pageController.position.hasViewportDimension) {
      return;
    }

    // Animate through categories - stop at a balanced middle position
    // Instead of going to the last icon, stop at index 4-5 for better balance
    final targetPosition =
        (widget.categories.length / 2) *
        _pageController.position.viewportDimension *
        0.25;

    await _pageController.animateTo(
      targetPosition,
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOutCubic,
    );

    // After animation completes, stop auto-rotation
    if (mounted) {
      setState(() {
        _autoRotating = false;
      });
    }
  }

  void _stopAutoRotation() {
    if (_autoRotating) {
      setState(() {
        _autoRotating = false;
      });
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) => _stopAutoRotation(),
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.categories.length,
        physics: _autoRotating
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildCategoryIcon(index);
        },
      ),
    );
  }

  Widget _buildCategoryIcon(int index) {
    // Calculate distance from current page (center position)
    final difference = (index - _currentPage).abs();

    // Calculate vertical offset using parabola for curve effect
    // Icons at center should be lower (more negative), icons at edges higher (less negative)
    final curveOffset = _calculateCurveOffset(difference);

    return GestureDetector(
      onTap: () {
        _stopAutoRotation();
        widget.onCategoryTap?.call(widget.categories[index]);
      },
      child: Transform.translate(
        offset: Offset(0, curveOffset),
        child: CategoryItem(
          category: widget.categories[index],
          onTap: () => widget.onCategoryTap?.call(widget.categories[index]),
        ),
      ),
    );
  }

  /// Calculate vertical offset to follow the green container's curve
  /// Center icons are DOWN (positive offset), edge icons are UP (negative offset)
  /// This matches the green container's dip curve from the Figma design
  double _calculateCurveOffset(double difference) {
    // The green container curves DOWN at the center (like a smile)
    // So icons at center need POSITIVE offset (move down)
    // Icons at edges need NEGATIVE offset (move up)

    const curveDepth = 25.0; // How much the center dips down

    // Parabolic curve calculation - INVERTED from previous
    // difference 0 (center) → offset = +25 (push down into the dip)
    // difference 2+ (edges) → offset = 0 (stay at baseline)
    final normalizedDiff = (difference / 2.0).clamp(0.0, 1.0);
    final curveValue =
        normalizedDiff * normalizedDiff; // x² gives parabolic shape
    final offset =
        curveDepth * (1 - curveValue); // Positive for center, 0 for edges

    return offset;
  }
}
