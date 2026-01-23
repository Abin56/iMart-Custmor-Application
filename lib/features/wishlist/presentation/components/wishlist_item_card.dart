import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/core/widgets/app_text.dart';
import '../../../../app/theme/colors.dart';
import '../../../cart/application/controllers/cart_controller.dart';
import '../../application/providers/wishlist_providers.dart';
import '../../domain/entities/wishlist_item.dart';

/// Wishlist Item Card
/// Shows product details with remove and add to cart buttons
class WishlistItemCard extends ConsumerStatefulWidget {
  const WishlistItemCard({required this.item, super.key});

  final WishlistItem item;

  @override
  ConsumerState<WishlistItemCard> createState() => _WishlistItemCardState();
}

class _WishlistItemCardState extends ConsumerState<WishlistItemCard> {
  bool _isRemoving = false;
  bool _isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            _buildProductImage(),

            SizedBox(width: 12.w),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  AppText(
                    text: widget.item.name,
                    fontSize: 16.sp,
                    color: Colors.black87,
                    maxLines: 2,
                  ),

                  SizedBox(height: 4.h),

                  // Unit Label
                  if (widget.item.unitLabel.isNotEmpty)
                    AppText(
                      text: widget.item.unitLabel,
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),

                  SizedBox(height: 8.h),

                  // Price Row
                  Row(
                    children: [
                      // Current Price
                      AppText(
                        text: '₹${widget.item.price.toStringAsFixed(2)}',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF25A63E),
                      ),

                      SizedBox(width: 8.w),

                      // Original Price (if discount)
                      if (widget.item.hasDiscount) ...[
                        AppText(
                          text: '₹${widget.item.mrp.toStringAsFixed(2)}',
                          fontSize: 14.sp,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                        SizedBox(width: 6.w),

                        // Discount Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: AppText(
                            text: '${widget.item.discountPct}% OFF',
                            fontSize: 10.sp,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Action Buttons
                  Row(
                    children: [
                      // Add to Cart Button
                      Expanded(child: _buildAddToCartButton()),

                      SizedBox(width: 8.w),

                      // Remove Button
                      _buildRemoveButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: widget.item.imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: widget.item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: const Color(0xFF25A63E),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.shopping_basket,
                  size: 40.sp,
                  color: Colors.grey,
                ),
              )
            : Icon(Icons.shopping_basket, size: 40.sp, color: Colors.grey),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return GestureDetector(
      onTap: _isAddingToCart ? null : _handleAddToCart,
      child: Container(
        height: 36.h,
        decoration: BoxDecoration(
          color: _isAddingToCart
              ? Colors.grey.shade300
              : const Color(0xFF25A63E),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: _isAddingToCart
              ? SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6.w),
                    AppText(
                      text: 'Add to Cart',
                      fontSize: 13.sp,
                      color: Colors.white,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return GestureDetector(
      onTap: _isRemoving ? null : _handleRemove,
      child: Container(
        width: 36.w,
        height: 36.h,
        decoration: BoxDecoration(
          color: _isRemoving ? Colors.grey.shade300 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: _isRemoving
              ? SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: Colors.red,
                  ),
                )
              : Icon(Icons.delete_outline, size: 20.sp, color: Colors.red),
        ),
      ),
    );
  }

  Future<void> _handleAddToCart() async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      await ref
          .read(cartControllerProvider.notifier)
          .addToCart(
            productVariantId: int.parse(widget.item.productId),
            quantity: 1,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Added to cart'),
            backgroundColor: const Color(0xFF25A63E),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Future<void> _handleRemove() async {
    setState(() {
      _isRemoving = true;
    });

    try {
      final success = await ref
          .read(wishlistProvider.notifier)
          .removeFromWishlist(widget.item.id.toString());

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Removed from wishlist'),
            backgroundColor: AppColors.grey,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRemoving = false;
        });
      }
    }
  }
}
