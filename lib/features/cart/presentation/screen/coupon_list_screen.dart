import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/core/widgets/app_text.dart';
import '../../../../app/theme/colors.dart';
import '../../application/controllers/cart_controller.dart';
import '../../application/controllers/coupon_controller.dart';
import '../../application/controllers/coupon_list_controller.dart';
import '../../domain/entities/coupon.dart';

/// Coupon List Screen
///
/// Displays available coupons with:
/// - Auto-refresh every 30 seconds when active
/// - Pull-to-refresh gesture
/// - HTTP 304 optimization for bandwidth savings
/// - Loading, empty, and error states
class CouponListScreen extends ConsumerStatefulWidget {
  const CouponListScreen({super.key});

  @override
  ConsumerState<CouponListScreen> createState() => _CouponListScreenState();
}

class _CouponListScreenState extends ConsumerState<CouponListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Start polling when screen is initialized
    Future.microtask(() {
      ref.read(couponListControllerProvider.notifier).startPolling();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Stop polling when screen is disposed
    ref.read(couponListControllerProvider.notifier).stopPolling();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  List<Coupon> _filterCoupons(List<Coupon> coupons) {
    if (_searchQuery.isEmpty) return coupons;

    final query = _searchQuery.toLowerCase();
    return coupons.where((coupon) {
      final matchesCode = coupon.name.toLowerCase().contains(query);
      final matchesDescription = coupon.description.toLowerCase().contains(
        query,
      );
      return matchesCode || matchesDescription;
    }).toList();
  }

  Future<void> _handleRefresh() async {
    await ref.read(couponListControllerProvider.notifier).refresh();
  }

  Future<void> _handleApplyCoupon(Coupon coupon) async {
    try {
      // Get cart total items for validation
      final cartState = ref.read(cartControllerProvider);
      final totalItems = cartState.totalItems;

      // Show loading indicator
      _showSnackBar('Applying coupon...', isLoading: true);

      // Validate coupon
      await ref
          .read(couponControllerProvider.notifier)
          .validateCoupon(code: coupon.name, checkoutItemsQuantity: totalItems);

      // Apply coupon
      await ref
          .read(couponControllerProvider.notifier)
          .applyCoupon(coupon.name);

      if (!mounted) return;

      // Show success message
      _showSnackBar('Coupon applied successfully!', isSuccess: true);

      // Navigate back after short delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      // Extract error message
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _showSnackBar(errorMessage, isError: true);
    }
  }

  Future<void> _handleCopyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    _showSnackBar('Coupon code copied!', isSuccess: true);
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
    bool isLoading = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (isLoading)
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            if (isLoading) SizedBox(width: 12.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? Colors.red
            : isSuccess
            ? const Color(0xFF25A63E)
            : const Color(0xFF4ECDC4),
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(couponListControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Header
          Container(height: 13.h, color: const Color(0xFF0D5C2E)),
          _buildHeader(),

          // Search bar
          _buildSearchBar(),

          // Content
          Expanded(
            child: state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (response, lastUpdated) {
                final coupons = response.availableCoupons;

                if (coupons.isEmpty) {
                  return _buildEmptyState();
                }

                final filteredCoupons = _filterCoupons(coupons);

                if (filteredCoupons.isEmpty) {
                  return _buildNoSearchResults();
                }

                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 16.h,
                    ),
                    itemCount: filteredCoupons.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildCouponCard(filteredCoupons[index]),
                      );
                    },
                  ),
                );
              },
              error: (message, cachedResponse) {
                final coupons = cachedResponse?.availableCoupons ?? [];

                if (coupons.isEmpty) {
                  return _buildErrorState(message);
                }

                final filteredCoupons = _filterCoupons(coupons);

                // Show cached data with error banner
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      color: Colors.orange.shade100,
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade800,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Showing cached coupons. Unable to refresh.',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filteredCoupons.isEmpty
                          ? _buildNoSearchResults()
                          : RefreshIndicator(
                              onRefresh: _handleRefresh,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18.w,
                                  vertical: 16.h,
                                ),
                                itemCount: filteredCoupons.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: _buildCouponCard(
                                      filteredCoupons[index],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 90.h,
      padding: EdgeInsets.only(
        top: 30.h,
        left: 20.w,
        right: 20.w,
        bottom: 10.h,
      ),
      decoration: const BoxDecoration(color: Color(0xFF0D5C2E)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.white,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          AppText(
            text: 'Available Coupons',
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20.sp, color: Colors.grey.shade600),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Search coupons...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: _clearSearch,
              child: Icon(
                Icons.clear,
                size: 20.sp,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            'No coupons found',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try searching with different keywords',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    final couponState = ref.watch(couponControllerProvider);
    final isApplied =
        couponState.hasCoupon && couponState.appliedCoupon?.name == coupon.name;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isApplied
              ? const Color(0xFF25A63E)
              : const Color(0xFF25A63E).withValues(alpha: 0.3),
          width: isApplied ? 2.w : 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Discount badge
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF25A63E), Color(0xFF1E8533)],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  coupon.formattedDiscount,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              // Validity text
              Text(
                coupon.validityDisplayText,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Coupon code - tappable to copy
          GestureDetector(
            onTap: () => _handleCopyCode(coupon.name),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    coupon.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.copy, size: 16.sp, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Description
          Text(
            coupon.description,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 12.h),

          // Bottom row: Usage stats + Apply button
          Row(
            children: [
              // Usage stats
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${coupon.usage}/${coupon.limit} used',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),

              const Spacer(),

              // Apply button
              if (isApplied)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25A63E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: const Color(0xFF25A63E),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16.sp,
                        color: const Color(0xFF25A63E),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Applied',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF25A63E),
                        ),
                      ),
                    ],
                  ),
                )
              else if (!coupon.isAvailable)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Unavailable',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () => _handleApplyCoupon(coupon),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF25A63E), Color(0xFF1E8533)],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25A63E).withValues(alpha: 0.3),
                          blurRadius: 6.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No coupons available',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Check back later for new offers',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red.shade400),
          SizedBox(height: 16.h),
          Text(
            'Failed to load coupons',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _handleRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25A63E),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
