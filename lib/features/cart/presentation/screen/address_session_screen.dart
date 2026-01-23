import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/core/widgets/app_text.dart';
import '../../../../app/theme/colors.dart';
import '../../../address/application/providers/address_providers.dart';
import '../../../address/domain/entities/address.dart';
import '../components/cart_stepper.dart';
import 'add_new_address_screen.dart';

/// Address Session Screen (Step 1)
/// Shows list of saved addresses with option to add new
class AddressSessionScreen extends ConsumerStatefulWidget {
  const AddressSessionScreen({
    super.key,
    this.onBackPressed,
    this.onProceedToPayment,
  });
  final VoidCallback? onBackPressed;
  final VoidCallback? onProceedToPayment;

  @override
  ConsumerState<AddressSessionScreen> createState() =>
      _AddressSessionScreenState();
}

class _AddressSessionScreenState extends ConsumerState<AddressSessionScreen> {
  int? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    // Load addresses when screen is opened
    Future.microtask(() {
      ref.read(addressNotifierProvider.notifier).loadAddresses();
    });
  }

  void _handleAddNewAddress() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const AddNewAddressScreen(),
      ),
    );
  }

  Future<void> _handleProceedToPayment() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery address'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Select the address on the backend
    final success = await ref
        .read(addressNotifierProvider.notifier)
        .selectAddress(_selectedAddressId!);

    if (success && mounted) {
      widget.onProceedToPayment?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Header
          Container(height: 13.h, color: const Color(0xFF0D5C2E)),
          _buildHeader(),

          // Progress Stepper
          const CartStepper(currentStep: 1),

          // Scrollable address list
          Expanded(
            child: addressState.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (addresses, selectedAddress) {
                // Auto-select the selected address from backend
                if (_selectedAddressId == null && selectedAddress != null) {
                  _selectedAddressId = selectedAddress.id;
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header
                      AppText(
                        text: 'Select Delivery Address',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Choose where you want your order delivered',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Add New Address Button
                      _buildAddNewAddressButton(),

                      SizedBox(height: 16.h),

                      // Address List
                      if (addresses.isEmpty)
                        _buildEmptyState()
                      else
                        ...addresses.map(
                          (address) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _buildAddressCard(address),
                          ),
                        ),

                      SizedBox(height: 80.h), // Space for button
                    ],
                  ),
                );
              },
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(
                      'Error loading addresses',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(addressNotifierProvider.notifier)
                            .loadAddresses(forceRefresh: true);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Proceed Button
          _buildProceedButton(),
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
            onTap: () {
              widget.onBackPressed?.call();
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
            text: 'Delivery Address',
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewAddressButton() {
    return GestureDetector(
      onTap: _handleAddNewAddress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFFF8555)],
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Add New Address',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 64.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No saved addresses',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add a delivery address to continue',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    final isSelected = _selectedAddressId == address.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddressId = address.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF25A63E) : Colors.grey.shade300,
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF25A63E).withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12.r : 8.r,
              offset: Offset(0, isSelected ? 4.h : 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type badge and selected tag
            Row(
              children: [
                // Type badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(
                      address.addressType,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTypeIcon(address.addressType),
                        size: 14.sp,
                        color: _getTypeColor(address.addressType),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        address.typeLabel,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: _getTypeColor(address.addressType),
                        ),
                      ),
                    ],
                  ),
                ),
                if (address.selected) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4ECDC4),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                // Radio button
                Container(
                  width: 22.w,
                  height: 22.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF25A63E)
                          : Colors.grey.shade400,
                      width: 2.w,
                    ),
                    color: isSelected
                        ? const Color(0xFF25A63E)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                      : null,
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Name
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16.sp,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 6.w),
                Text(
                  address.fullName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16.sp,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    address.fullAddress,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade700,
                      height: 1.4,
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

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return const Color(0xFF25A63E);
      case 'work':
        return const Color(0xFFFF6B35);
      case 'other':
        return const Color(0xFF4ECDC4);
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.business_outlined;
      case 'other':
        return Icons.location_on_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  Widget _buildProceedButton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: _handleProceedToPayment,
        child: Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: const Color(0xFF25A63E),
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF25A63E).withValues(alpha: 0.3),
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Proceed to Payment',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
