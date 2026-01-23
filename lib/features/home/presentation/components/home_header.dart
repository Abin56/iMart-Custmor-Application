import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Header row with location and profile icon
/// Displays delivery address and opens profile drawer
class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.address, this.onProfileTap, super.key});

  final String address;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationIcon(),
          SizedBox(width: 8.w),
          _buildAddressColumn(),
          SizedBox(width: 12.w),
          _buildProfileButton(context),
        ],
      ),
    );
  }

  Widget _buildLocationIcon() {
    return Icon(Icons.location_on, color: Colors.white, size: 24.sp);
  }

  Widget _buildAddressColumn() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivering To',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            address,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          if (onProfileTap != null) {
            onProfileTap!.call();
          } else {
            // Default behavior: open end drawer
            Scaffold.of(context).openEndDrawer();
          }
        },
        child: Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: const Color(0xFF0D4A26),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2.w,
            ),
          ),
          child: Icon(Icons.person_outline, color: Colors.white, size: 26.sp),
        ),
      ),
    );
  }
}
