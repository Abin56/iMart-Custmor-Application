import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../models/category_product.dart';

/// Product Detail Screen - Shows detailed product information
/// Features:
/// - Image carousel with navigation arrows
/// - Back button and favorite button
/// - Product name, price, and rating
/// - Quantity selector dropdown
/// - Product description
/// - Add to Basket button
class ProductDetailScreen extends StatefulWidget {
  final CategoryProduct product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  String _selectedQuantity = '1Kg';
  int _cartQuantity = 0;

  final List<String> _quantities = ['500g', '1Kg', '2Kg', '5Kg'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Image carousel section with green background
          _buildImageCarousel(),

          // Product details section
          Expanded(child: SingleChildScrollView(child: _buildProductDetails())),

          // Add to Basket button
          _buildAddToBasketButton(),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Container(
      height: 320.h,
      decoration: const BoxDecoration(color: Color(0xFF0D5C2E)),
      child: Stack(
        children: [
          // Main product image with decorative arc
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 80.h),
              width: double.infinity,
              height: 150.h,
              child: Stack(
                children: [
                  // Decorative arc overlay
                  CustomPaint(
                    size: Size(double.infinity, 100.h),
                    painter: _CurvedArcPainter(),
                  ),

                  Image.asset(
                    'assets/images/fruits.png', // Placeholder image
                    fit: BoxFit.fitHeight,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ],
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 30.h,
            left: 20.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 45.w,
                height: 45.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back,
                  size: 24.sp,
                  color: AppColors.black,
                ),
              ),
            ),
          ),

          // Favorite button
          Positioned(
            top: 30.h,
            right: 20.w,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
              },
              child: Container(
                width: 45.w,
                height: 45.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C4A3A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 24.sp,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
              ),
            ),
          ),

          // Left navigation arrow
          Positioned(
            left: 20.w,
            top: 200.h,
            child: GestureDetector(
              onTap: () {
                if (_currentImageIndex > 0) {
                  setState(() {
                    _currentImageIndex--;
                  });
                }
              },
              child: Icon(Icons.chevron_left, size: 40.sp, color: Colors.black),
            ),
          ),

          // Right navigation arrow
          Positioned(
            right: 20.w,
            top: 200.h,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentImageIndex = (_currentImageIndex + 1) % 3;
                });
              },
              child: Icon(
                Icons.chevron_right,
                size: 40.sp,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return ClipPath(
      clipper: _BottomShadowClipper(),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.r),
            topRight: Radius.circular(40.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10.r,
              offset: Offset(0, -2.h),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Product name and quantity selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText(
                  text: widget.product.name,
                  fontSize: 30.sp,
                  // fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              SizedBox(width: 16.w),
              // Quantity selector
              Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () => _showQuantityMenu(context),
                    child: Container(
                      width: 95.w,
                      height: 35.h,
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF25A63E),
                          // width: 2.w,
                        ),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Qty ',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                          Text(
                            _selectedQuantity,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF25A63E),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black,
                            size: 18.sp,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Price section
          AppText(
            text: 'Price',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey,
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              if (widget.product.originalPrice != null) ...[
                Text(
                  '₹ ${widget.product.originalPrice}',
                  style: TextStyle(
                          fontSize: 20.sp,
                  fontWeight: FontWeight.w400,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Text(
                '₹ ${widget.product.price}',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF25A63E),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Rating
          Row(
            children: [
              Icon(Icons.star, size: 24.sp, color: Colors.amber),
              SizedBox(width: 8.w),
              AppText(
                text: '4.5',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
              SizedBox(width: 4.w),
              AppText(
                text: '(50 reviews)',
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.black,
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Description
          Text(
            '"Losse cillum dolore eu fugiat nullariatur.Losse cillum dolore eu fugriatur.Losse cillum dolore eu fugriatur.Losse cillum dolore eu fugriatur.Losse cillum dolore eu fugriatur.Losse cillum dolore eu fugriatur.Losse cillum dolore eu fugriatur.Losse cillum dolore eu fugriatur.Losse cillum dolore eu fugriatur.Losse cillum dolore eu fugriatur.Losse cillum dolore eu fugriatur.Losse cillum dolore eu fugriatur.Losse cillum dolore eu fugriatur.Losse cillum dolore eu fugriatur.Losse cillum dolore eu fug pariatur.Losse cillum dolore eu fugiat nulla pariatur.',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
              height: 1.6,
            ),
          ),

          SizedBox(height: 40.h),
        ],
      ),
      ),
    );
  }

  void _showQuantityMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu<String>(
      color: Colors.white,
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + button.size.height + 0.h,
        buttonPosition.dx + button.size.width,
        0,
      ),
      shape: const RoundedRectangleBorder(
        // side: const BorderSide(color: Color(0xFF25A63E)),
      ),
      elevation: 8,
      constraints: BoxConstraints(
        minWidth: button.size.width,
        maxWidth: button.size.width,
      ),
      items: _quantities.map((String value) {
        final isSelected = value == _selectedQuantity;
        return PopupMenuItem<String>(
          value: value,

          padding: EdgeInsets.zero,
          height: 28.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF25A63E) : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Qty',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.black,
                  ),
                ),
                SizedBox(width: 20.w),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF25A63E),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedQuantity = value;
        });
      }
    });
  }

  Widget _buildAddToBasketButton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: _cartQuantity == 0
          ? GestureDetector(
              onTap: () {
                setState(() {
                  _cartQuantity = 1;
                });
              },
              child: Container(
                height: 60.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D5C2E),
                  borderRadius: BorderRadius.circular(50.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D5C2E).withValues(alpha: 0.3),
                      blurRadius: 20.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    AppText(
                      text: 'Add to Basket',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            )
          : Row(
              children: [
                // Minus button - Outside
                GestureDetector(
                  onTap: () {
                    if (_cartQuantity > 0) {
                      setState(() {
                        _cartQuantity--;
                      });
                    }
                  },
                  child: Container(
                    width: 35.w,
                    height: 35.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0D5C2E),
                        width: 2.w,
                      ),
                    ),
                    child: Icon(
                      Icons.remove,
                      color: const Color(0xFF0D5C2E),
                      size: 22.sp,
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // Quantity display with border
                Container(
                  width: 38.w,
                  height: 35.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: const Color(0xFF0D5C2E),
                      width: 1.w,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$_cartQuantity',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0D5C2E),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // Plus button - Outside
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _cartQuantity++;
                    });
                  },
                  child: Container(
                    width: 35.w,
                    height: 35.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D5C2E),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // View Basket button - Right side
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to cart/basket screen
                      // TODO: Implement navigation to cart
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Navigate to Basket with $_cartQuantity items'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      height: 60.h,
                      decoration: BoxDecoration(
                        color:  const Color(0xFF0D5C2E),
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                          SizedBox(width: 8.w),
                          AppText(
                            text: 'View Basket',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Custom painter for the curved arc decoration on the white circle
class _CurvedArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Main product image width (same as container image)
    double imageWidth = size.width * 0.59;

    // RADIUS — bigger means deeper curve
    double radius = imageWidth * 1.8;

    // CENTER — push down the arc
    double centerX = size.width / 2;
    double centerY = radius * 0.9;

    final arcPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();

    // ---- LOWER SMOOTH ARC ----
    path.addArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      math.pi * 1.29, // starting angle
      math.pi * 1.64, // how wide the curve spreads
    );

    canvas.drawPath(path, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom clipper to hide bottom shadow
class _BottomShadowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start from top-left, extend beyond the shadow area on top and sides
    path.moveTo(-20, -20);
    path.lineTo(size.width + 20, -20);
    path.lineTo(size.width + 20, size.height);
    path.lineTo(-20, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
