import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_spacing.dart';

/// Bill summary component showing subtotal, tax, delivery charges, discount, and total
class BillSummary extends StatelessWidget {
  const BillSummary({
    required this.subtotal,
    required this.tax,
    required this.deliveryCharges,
    required this.total,
    this.discount,
    super.key,
  });
  final String subtotal;
  final String tax;
  final String deliveryCharges;
  final String total;
  final String? discount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 20.w, left: 20.w, top: 15.h),
      child: Column(
        children: [
          _buildBillRow('Subtotal', subtotal),
          AppSpacing.h8,
          _buildBillRow('TAX (2%)', tax),
          AppSpacing.h8,
          _buildBillRow('Delivery Charges', deliveryCharges),
          if (discount != null) ...[
            AppSpacing.h8,
            _buildBillRow('Discount', discount!, isDiscount: true),
          ],
          Divider(height: 24.h, thickness: 1),
          _buildBillRow('Total', total, isBold: true),
        ],
      ),
    );
  }

  Widget _buildBillRow(
    String label,
    String value, {
    bool isBold = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18.sp : 14.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isDiscount
                ? const Color(0xFF25A63E)
                : (isBold ? Colors.black : Colors.black87),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 20.sp : 14.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isDiscount ? const Color(0xFF25A63E) : Colors.black,
          ),
        ),
      ],
    );
  }
}
