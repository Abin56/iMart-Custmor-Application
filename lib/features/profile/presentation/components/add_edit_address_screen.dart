import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../../../app/theme/colors.dart';
import '../../../auth/domain/entities/address.dart';
import '../../application/providers/address_provider.dart';

/// Add/Edit Address Screen
/// Allows users to add new or edit existing delivery addresses
class AddEditAddressScreen extends ConsumerStatefulWidget {
  const AddEditAddressScreen({
    super.key,
    this.isEdit = false,
    this.addressType,
    this.address,
  });
  final bool isEdit;
  final String? addressType;
  final AddressEntity? address;

  @override
  ConsumerState<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedAddressType = 'Home';
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();

    // Initialize with edit data if editing
    if (widget.isEdit && widget.address != null) {
      final addr = widget.address!;
      _selectedAddressType =
          addr.addressType.name.substring(0, 1).toUpperCase() +
          addr.addressType.name.substring(1);
      _nameController.text = '${addr.firstName} ${addr.lastName}'.trim();
      _phoneController.text = ''; // Phone not stored in AddressEntity
      _addressLine1Controller.text = addr.streetAddress1;
      _addressLine2Controller.text = addr.streetAddress2 ?? '';
      _cityController.text = addr.city ?? '';
      _stateController.text = addr.state ?? '';
      _pincodeController.text = ''; // Pincode not stored in AddressEntity
      _isDefault = addr.selected;
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      // Parse name into first and last name
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      try {
        if (widget.isEdit && widget.address != null) {
          // Update existing address
          await ref
              .read(addressProvider.notifier)
              .updateAddress(
                id: widget.address!.id,
                firstName: firstName,
                lastName: lastName,
                streetAddress1: _addressLine1Controller.text.trim(),
                city: _cityController.text.trim(),
                addressState: _stateController.text.trim(),
                addressType: _selectedAddressType,
                streetAddress2: _addressLine2Controller.text.trim().isEmpty
                    ? null
                    : _addressLine2Controller.text.trim(),
                selected: _isDefault,
              );
        } else {
          // Add new address
          await ref
              .read(addressProvider.notifier)
              .addAddress(
                firstName: firstName,
                lastName: lastName,
                streetAddress1: _addressLine1Controller.text.trim(),
                city: _cityController.text.trim(),
                addressState: _stateController.text.trim(),
                addressType: _selectedAddressType,
                streetAddress2: _addressLine2Controller.text.trim().isEmpty
                    ? null
                    : _addressLine2Controller.text.trim(),
                selected: _isDefault,
              );
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Success!',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.isEdit
                              ? 'Address updated successfully'
                              : 'Address added successfully',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF25A63E),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.all(16.w),
            ),
          );

          // Navigate back with delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Failed to save address. Please try again.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.all(16.w),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Scrollable content with animation
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Address Type Selection
                        _buildSectionTitle('Address Type'),
                        SizedBox(height: 12.h),
                        _buildAddressTypeSelector(),

                        SizedBox(height: 24.h),

                        // Full Name
                        _buildSectionTitle('Full Name'),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'Enter your full name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 20.h),

                        // Phone Number
                        _buildSectionTitle('Phone Number'),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _phoneController,
                          hintText: 'Enter phone number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone number';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 20.h),

                        // Address Line 1
                        _buildSectionTitle('Address Line 1'),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _addressLine1Controller,
                          hintText: 'House No., Building Name',
                          icon: Icons.home_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter address';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 20.h),

                        // Address Line 2
                        _buildSectionTitle('Address Line 2'),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _addressLine2Controller,
                          hintText: 'Road name, Area, Colony',
                          icon: Icons.location_on_outlined,
                        ),

                        SizedBox(height: 20.h),

                        // City and State (Row)
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('City'),
                                  SizedBox(height: 8.h),
                                  _buildTextField(
                                    controller: _cityController,
                                    hintText: 'City',
                                    icon: Icons.location_city_outlined,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter city';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('State'),
                                  SizedBox(height: 8.h),
                                  _buildTextField(
                                    controller: _stateController,
                                    hintText: 'State',
                                    icon: Icons.map_outlined,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter state';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        // Pincode
                        _buildSectionTitle('Pincode'),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _pincodeController,
                          hintText: 'Enter pincode',
                          icon: Icons.pin_drop_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter pincode';
                            }
                            if (value.length != 6) {
                              return 'Please enter valid 6-digit pincode';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 24.h),

                        // Set as default checkbox
                        _buildDefaultCheckbox(),

                        SizedBox(height: 40.h),

                        // Save button
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
            text: widget.isEdit ? 'Edit Address' : 'Add New Address',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0D5C2E),
      ),
    );
  }

  Widget _buildAddressTypeSelector() {
    final types = [
      {'label': 'Home', 'icon': Icons.home_rounded},
      {'label': 'Work', 'icon': Icons.work_rounded},
      {'label': 'Other', 'icon': Icons.location_on_rounded},
    ];

    return Row(
      children: types.map((type) {
        final isSelected = _selectedAddressType == type['label'];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type['label'] == 'Other' ? 0 : 12.w,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAddressType = type['label']! as String;
                });
              },
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF25A63E), Color(0xFF1B7A43)],
                        )
                      : null,
                  color: isSelected ? null : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF25A63E)
                        : Colors.grey.shade300,
                    width: isSelected ? 2.w : 1.w,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type['icon']! as IconData,
                      size: 24.sp,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      type['label']! as String,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade500,
          ),
          prefixIcon: Icon(icon, size: 20.sp, color: const Color(0xFF25A63E)),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5.w),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5.w),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: const Color(0xFF25A63E), width: 2.w),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2.w),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2.w),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultCheckbox() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isDefault = !_isDefault;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: _isDefault
              ? const Color(0xFF25A63E).withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: _isDefault ? const Color(0xFF25A63E) : Colors.grey.shade300,
            width: _isDefault ? 2.w : 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                gradient: _isDefault
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF25A63E), Color(0xFF1B7A43)],
                      )
                    : null,
                color: _isDefault ? null : Colors.white,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: _isDefault
                      ? const Color(0xFF25A63E)
                      : Colors.grey.shade400,
                  width: 2.w,
                ),
              ),
              child: _isDefault
                  ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set as default address',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'This address will be used for all future orders',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _handleSave,
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF25A63E), // Bright green
              Color(0xFF1B7A43), // Medium green
            ],
          ),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF25A63E).withValues(alpha: 0.4),
              blurRadius: 25.r,
              offset: Offset(0, 10.h),
            ),
            BoxShadow(
              color: const Color(0xFF25A63E).withValues(alpha: 0.2),
              blurRadius: 15.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isEdit
                  ? Icons.check_circle_outline
                  : Icons.add_location_alt,
              color: Colors.white,
              size: 24.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              widget.isEdit ? 'Update Address' : 'Save Address',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
