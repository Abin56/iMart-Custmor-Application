import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app/theme/app_spacing.dart';

/// Reusable quantity selector widget with plus/minus buttons
/// Used in product cards and cart items
class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    required this.quantity,
    required this.onQuantityChanged,
    this.minQuantity = 0,
    super.key,
  });

  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final int minQuantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(icon: Icons.remove, onTap: _decrementQuantity),
          AppSpacing.w8,
          _buildQuantityDisplay(),
          AppSpacing.w8,
          _buildButton(icon: Icons.add, onTap: _incrementQuantity),
        ],
      ),
    );
  }

  Widget _buildButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20.w,
        height: 20.h,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all()),
        child: Center(
          child: Icon(icon, size: 15.sp, color: const Color(0xFF25A63E)),
        ),
      ),
    );
  }

  Widget _buildQuantityDisplay() {
    return Container(
      width: 20.w,
      alignment: Alignment.center,
      child: Text(
        '$quantity',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  void _incrementQuantity() {
    onQuantityChanged(quantity + 1);
  }

  void _decrementQuantity() {
    if (quantity > minQuantity) {
      onQuantityChanged(quantity - 1);
    }
  }
}
