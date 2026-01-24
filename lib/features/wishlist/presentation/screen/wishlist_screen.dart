import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/core/error/failure.dart';
import '../../../../app/core/widgets/app_text.dart';
import '../../../../app/theme/colors.dart';
import '../../application/providers/wishlist_providers.dart';
import '../../application/states/wishlist_state.dart';
import '../../domain/entities/wishlist_item.dart';
import '../components/empty_wishlist.dart';
import '../components/wishlist_product_card.dart';

/// Wishlist Screen
/// Shows saved wishlist items with remove and add to cart functionality
class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key, this.onBackPressed, this.onStartShopping});
  final VoidCallback? onBackPressed;
  final VoidCallback? onStartShopping;

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  @override
  Widget build(BuildContext context) {
    final wishlistState = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Header
          Container(height: 13.h, color: const Color(0xFF0D5C2E)),
          _buildHeader(),

          // Content
          Expanded(
            child: wishlistState.when(
              initial: _buildEmptyState,
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (items, isRefreshing) => items.isEmpty
                  ? _buildEmptyState()
                  : _buildWishlistContent(items),
              refreshing: _buildWishlistContent,
              error: (failure, previousState) =>
                  previousState != null && previousState.hasItems
                  ? _buildWishlistContentWithError(previousState.items, failure)
                  : _buildErrorState(failure),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final count = ref.watch(wishlistCountProvider);

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
            onTap: () {
              // If callback is provided, use it (tab navigation)
              // Otherwise use context.pop() for proper navigation
              if (widget.onBackPressed != null) {
                widget.onBackPressed!.call();
              } else if (context.canPop()) {
                context.pop();
              }
            },
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
            text: 'My Wishlist',
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          if (count > 0) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: AppText(
                text: '$count',
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWishlistContent(List items) {
    return RefreshIndicator(
      onRefresh: () => ref.read(wishlistProvider.notifier).refresh(),
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
          mainAxisExtent: 175.h,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final wishlistItem = items[index] as WishlistItem;

          return WishlistProductCard(item: wishlistItem, onTap: () {});
        },
      ),
    );
  }

  Widget _buildWishlistContentWithError(List items, failure) {
    return Column(
      children: [
        // Error banner
        Container(
          color: Colors.red.shade100,
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  failure.toString(),
                  style: TextStyle(color: Colors.red.shade900, fontSize: 14.sp),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(wishlistProvider.notifier).clearError();
                },
                child: Text('Dismiss', style: TextStyle(fontSize: 12.sp)),
              ),
            ],
          ),
        ),

        // Show previous data
        Expanded(child: _buildWishlistContent(items)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return EmptyWishlist(
      onStartShopping: () {
        // If callback provided, use it (navigates to category tab)
        // Otherwise just pop back
        if (widget.onStartShopping != null) {
          widget.onStartShopping!.call();
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }

  Widget _buildErrorState(Failure failure) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            AppText(
              text: 'Unable to load wishlist',
              fontSize: 18.sp,
              color: Colors.grey.shade800,
            ),
            SizedBox(height: 8.h),
            AppText(
              text: failure.toString(),
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                ref.read(wishlistProvider.notifier).refresh();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25A63E),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: AppText(
                text: 'Try Again',
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
