import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../application/providers/order_provider.dart';
import '../../application/states/order_state.dart';

/// Order Items Bottom Sheet
/// Displays the list of items in an order
class OrderItemsBottomSheet extends ConsumerStatefulWidget {
  const OrderItemsBottomSheet({required this.orderId, super.key});
  final int orderId;

  @override
  ConsumerState<OrderItemsBottomSheet> createState() =>
      _OrderItemsBottomSheetState();
}

class _OrderItemsBottomSheetState extends ConsumerState<OrderItemsBottomSheet> {
  @override
  void initState() {
    super.initState();
    print('🔵 [OrderItemsBottomSheet] ========================================');
    print('🔵 [OrderItemsBottomSheet] initState called for orderId: ${widget.orderId}');
    print('🔵 [OrderItemsBottomSheet] Current state before loading: ${ref.read(orderProvider).runtimeType}');
    if (ref.read(orderProvider) is OrderItemsLoaded) {
      final currentState = ref.read(orderProvider) as OrderItemsLoaded;
      print('🔵 [OrderItemsBottomSheet] Previous state had orderId: ${currentState.orderId} with ${currentState.items.length} items');
    }
    // Load order items when bottom sheet opens
    Future.microtask(
      () {
        print('🔵 [OrderItemsBottomSheet] Calling loadOrderItems for orderId: ${widget.orderId}');
        ref
            .read(orderProvider.notifier)
            .loadOrderItems(orderId: widget.orderId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    print('🔵 [OrderItemsBottomSheet] build called, state type: ${orderState.runtimeType}');
    print('🔵 [OrderItemsBottomSheet] widget.orderId = ${widget.orderId}');

    if (orderState is OrderItemsLoaded) {
      print('🔵 [OrderItemsBottomSheet] orderState.orderId = ${orderState.orderId}');
      print('🔵 [OrderItemsBottomSheet] Match? ${orderState.orderId == widget.orderId}');
      print('🔵 [OrderItemsBottomSheet] Items count: ${orderState.items.length}');
      for (var i = 0; i < orderState.items.length; i++) {
        print('   [${i + 1}] ${orderState.items[i].productName} (Order: ${orderState.items[i].orderId})');
      }
    } else if (orderState is OrderItemsLoading) {
      print('🔵 [OrderItemsBottomSheet] OrderItemsLoading.orderId = ${orderState.orderId}');
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // Title
                Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF25A63E).withValues(alpha: 0.2),
                            const Color(0xFF0D5C2E).withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 24.sp,
                        color: const Color(0xFF25A63E),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: 'Order Items',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          Builder(
                            builder: (context) {
                              final state = ref.watch(orderProvider);
                              var itemsText = 'Loading...';
                              if (state is OrderItemsLoaded &&
                                  state.orderId == widget.orderId) {
                                itemsText =
                                    '${state.items.length} ${state.items.length == 1 ? 'Item' : 'Items'}';
                              }
                              return Text(
                                'Order #${widget.orderId} • $itemsText',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: orderState is OrderItemsLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(height: 16.h),
                        Text(
                          'Loading items...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : orderState is OrderItemsLoaded &&
                      orderState.orderId == widget.orderId
                ? Builder(
                    builder: (context) {
                      print('🟢 [OrderItemsBottomSheet] Displaying ${orderState.items.length} items');
                      return ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        itemCount: orderState.items.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final item = orderState.items[index];
                          return _buildOrderItem(
                            name: item.productName,
                            quantity: '${item.quantity} x ${item.formattedPrice}',
                            price: item.totalPrice,
                            imageUrl: item.productImage,
                          );
                        },
                      );
                    },
                  )
                : orderState is OrderError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.sp,
                          color: Colors.red.shade400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Failed to load items',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          orderState.failure.message,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : const Center(child: Text('Loading items...')),
          ),

          // Footer with total
          if (orderState is OrderItemsLoaded &&
              orderState.orderId == widget.orderId)
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, -2.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Subtotal row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        '₹${orderState.subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Total items count row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Items',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        '${orderState.totalItemsCount}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Divider(
                    height: 1.h,
                    thickness: 1.h,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 12.h),
                  // Total row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order Total',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '₹${orderState.subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF25A63E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItem({
    required String name,
    required String quantity,
    required double price,
    required String? imageUrl,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.w),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade200, width: 1.w),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.shopping_bag_outlined,
                          size: 30.sp,
                          color: Colors.grey.shade400,
                        );
                      },
                    )
                  : Icon(
                      Icons.shopping_bag_outlined,
                      size: 30.sp,
                      color: Colors.grey.shade400,
                    ),
            ),
          ),

          SizedBox(width: 12.w),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25A63E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    quantity,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF25A63E),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // Price
          Text(
            '₹${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
