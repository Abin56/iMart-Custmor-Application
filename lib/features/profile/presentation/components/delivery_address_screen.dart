import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:imart/app/core/utils/address_enum.dart';
import 'package:imart/features/auth/domain/entities/address.dart';
import 'package:imart/features/profile/application/providers/address_provider.dart';
import 'package:imart/features/profile/application/states/address_state.dart';
import 'package:imart/features/profile/presentation/components/add_edit_address_screen.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../../../app/theme/colors.dart';

/// Delivery Address Screen
/// Displays and manages user's saved delivery addresses
class DeliveryAddressScreen extends ConsumerStatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  ConsumerState<DeliveryAddressScreen> createState() =>
      _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends ConsumerState<DeliveryAddressScreen> {
  int? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    // Load addresses on screen init
    Future.microtask(
      () => ref.read(addressProvider.notifier).refreshAddresses(),
    );
  }

  IconData _getAddressIcon(AddressType type) {
    switch (type) {
      case AddressType.home:
        return Icons.home_rounded;
      case AddressType.work:
        return Icons.work_rounded;
      case AddressType.other:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Addresses list
          Expanded(
            child: addressState is AddressLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF25A63E)),
                  )
                : addressState is AddressLoaded
                ? addressState.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off_outlined,
                                size: 80.sp,
                                color: Colors.grey.shade300,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No addresses saved',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Add your first delivery address',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
                          itemCount: addressState.addresses.length,
                          itemBuilder: (context, index) {
                            final address = addressState.addresses[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: _buildAddressCard(
                                addressEntity: address,
                                id: address.id,
                                type: address.addressType.name.toUpperCase(),
                                icon: _getAddressIcon(address.addressType),
                                name:
                                    '${address.firstName} ${address.lastName}',
                                address:
                                    '${address.streetAddress1}${address.streetAddress2 != null ? ', ${address.streetAddress2}' : ''}, ${address.city}, ${address.state}',
                                phone: '', // Phone not in address entity
                                isDefault: address.selected,
                              ),
                            );
                          },
                        )
                : addressState is AddressError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80.sp,
                          color: Colors.red.shade300,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Failed to load addresses',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          addressState.failure.message,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(addressProvider.notifier)
                                .refreshAddresses();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25A63E),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      // Floating add button
      floatingActionButton: _buildAddButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 100.h,
      padding: EdgeInsets.only(
        top: 20.h,
        left: 20.w,
        right: 20.w,
        bottom: 16.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D5C2E), // Dark green
            Color(0xFF1B7A43), // Medium green
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D5C2E).withValues(alpha: 0.3),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5.w,
                ),
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
            text: 'Delivery Address',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard({
    required int id,
    required String type,
    required IconData icon,
    required String name,
    required String address,
    required String phone,
    required bool isDefault,
    AddressEntity? addressEntity,
  }) {
    final isSelected = _selectedAddressId == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddressId = id;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF25A63E) : Colors.grey.shade300,
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF25A63E).withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 15.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Icon
                Container(
                  width: 44.w,
                  height: 44.h,
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
                    icon,
                    size: 24.sp,
                    color: const Color(0xFF25A63E),
                  ),
                ),

                SizedBox(width: 12.w),

                // Type
                Expanded(
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),

                // Default badge
                if (isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF25A63E), Color(0xFF1B7A43)],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),

                SizedBox(width: 8.w),

                // Radio button
                Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF25A63E)
                          : Colors.grey.shade400,
                      width: 2.w,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12.w,
                            height: 12.h,
                            decoration: const BoxDecoration(
                              color: Color(0xFF25A63E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Name
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16.sp,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 8.w),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16.sp,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Phone
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16.sp,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 8.w),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Action buttons
            Row(
              children: [
                // Edit button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to edit address screen
                      if (addressEntity != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditAddressScreen(
                              isEdit: true,
                              addressType: type,
                              address: addressEntity,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 38.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF25A63E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: const Color(0xFF25A63E).withValues(alpha: 0.3),
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 16.sp,
                            color: const Color(0xFF25A63E),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF25A63E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // Delete button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Handle delete
                      if (addressEntity != null) {
                        _showDeleteConfirmation(type, addressEntity.id);
                      }
                    },
                    child: Container(
                      height: 38.h,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: Colors.red.shade200,
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 16.sp,
                            color: Colors.red.shade600,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        // Navigate to add address screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditAddressScreen()),
        );
      },
      child: Container(
        width: 64.w,
        height: 64.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF25A63E), // Bright green
              Color(0xFF1B7A43), // Medium green
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF25A63E).withValues(alpha: 0.4),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Icon(Icons.add, size: 32.sp, color: Colors.white),
      ),
    );
  }

  void _showDeleteConfirmation(String type, int addressId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red.shade600,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Delete Address',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this $type address?',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Call addressProvider to delete
              await ref
                  .read(addressProvider.notifier)
                  .deleteAddress(id: addressId);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$type address deleted'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
