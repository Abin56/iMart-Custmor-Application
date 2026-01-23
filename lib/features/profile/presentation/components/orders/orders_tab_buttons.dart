import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Tab buttons widget for switching between Active and Previous orders
class OrdersTabButtons extends StatelessWidget {
  const OrdersTabButtons({
    required this.isActiveTab,
    required this.onTabChanged,
    super.key,
  });

  /// Whether the Active tab is currently selected
  final bool isActiveTab;

  /// Callback when tab is changed
  final ValueChanged<bool> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: _TabButton(
              label: 'Previous',
              isSelected: !isActiveTab,
              onTap: () => onTabChanged(false),
            ),
          ),

          SizedBox(width: 16.w),

          // Active button
          Expanded(
            child: _TabButton(
              label: 'Active',
              isSelected: isActiveTab,
              onTap: () => onTabChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual tab button widget
class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF25A63E) : Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: const Color(0xFF25A63E), width: 2.w),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF25A63E),
            ),
          ),
        ),
      ),
    );
  }
}
