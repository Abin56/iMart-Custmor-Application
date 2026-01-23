import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/core/widgets/app_text.dart';
import '../../../../app/theme/colors.dart';
import '../../../address/application/providers/address_providers.dart';
import 'map_location_picker_screen.dart';

/// Add New Address Screen with backend integration
class AddNewAddressScreen extends ConsumerStatefulWidget {
  const AddNewAddressScreen({super.key});

  @override
  ConsumerState<AddNewAddressScreen> createState() =>
      _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends ConsumerState<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Focus nodes for keyboard navigation
  final _nameFocusNode = FocusNode();
  final _addressLine1FocusNode = FocusNode();
  final _addressLine2FocusNode = FocusNode();
  final _cityFocusNode = FocusNode();
  final _stateFocusNode = FocusNode();
  final _pincodeFocusNode = FocusNode();

  String _selectedType = 'home';
  String? _latitude;
  String? _longitude;
  bool _isLoadingLocation = false;
  bool _isSaving = false;
  bool _setAsDefault = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _nameFocusNode.dispose();
    _addressLine1FocusNode.dispose();
    _addressLine2FocusNode.dispose();
    _cityFocusNode.dispose();
    _stateFocusNode.dispose();
    _pincodeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleUseCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Navigate to map location picker screen
      final result = await Navigator.push<Map<String, String>>(
        context,
        MaterialPageRoute(
          builder: (context) => const MapLocationPickerScreen(),
        ),
      );

      if (result != null && mounted) {
        // Limit latitude/longitude to 6 decimal places (sufficient for ~10cm accuracy)
        String? lat;
        String? lng;
        if (result['latitude'] != null) {
          final latDouble = double.tryParse(result['latitude']!);
          if (latDouble != null) {
            lat = latDouble.toStringAsFixed(6);
          }
        }
        if (result['longitude'] != null) {
          final lngDouble = double.tryParse(result['longitude']!);
          if (lngDouble != null) {
            lng = lngDouble.toStringAsFixed(6);
          }
        }

        setState(() {
          _addressLine1Controller.text = result['address1'] ?? '';
          _addressLine2Controller.text = result['address2'] ?? '';
          _cityController.text = result['city'] ?? '';
          _stateController.text = result['state'] ?? '';
          _pincodeController.text = result['pincode'] ?? '';
          _latitude = lat;
          _longitude = lng;
          _isLoadingLocation = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location detected successfully'),
              backgroundColor: const Color(0xFF25A63E),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleSaveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Parse name into first and last name
      final fullName = _nameController.text.trim();
      final nameParts = fullName.split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : firstName;

      // Create address using backend
      final address = await ref
          .read(addressNotifierProvider.notifier)
          .createAddress(
            firstName: firstName,
            lastName: lastName,
            streetAddress1: _addressLine1Controller.text.trim(),
            city: _cityController.text.trim(),
            stateProvince: _stateController.text.trim(),
            postalCode: _pincodeController.text.trim(),
            country: 'India',
            addressType: _selectedType,
            streetAddress2: _addressLine2Controller.text.trim().isNotEmpty
                ? _addressLine2Controller.text.trim()
                : null,
            latitude: _latitude,
            longitude: _longitude,
          );

      setState(() {
        _isSaving = false;
      });

      if (address != null && mounted) {
        // If "Set as default" is checked, mark this address as selected
        if (_setAsDefault) {
          await ref
              .read(addressNotifierProvider.notifier)
              .selectAddress(address.id);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Address saved successfully'),
              backgroundColor: const Color(0xFF25A63E),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save address'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Header
          Container(height: 13.h, color: const Color(0xFF0D5C2E)),
          _buildHeader(),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use Current Location Button
                    _buildUseCurrentLocationButton(),

                    SizedBox(height: 20.h),

                    // Address Type Selection
                    AppText(
                      text: 'Address Type',
                      fontSize: 15.sp,
                      color: AppColors.black,
                    ),
                    SizedBox(height: 12.h),
                    _buildTypeSelector(),

                    SizedBox(height: 24.h),

                    // Name field
                    _buildTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      nextFocusNode: _addressLine1FocusNode,
                      icon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16.h),

                    // Address Line 1
                    _buildTextField(
                      label: 'Address Line 1 (House No, Building Name)',
                      controller: _addressLine1Controller,
                      focusNode: _addressLine1FocusNode,
                      nextFocusNode: _addressLine2FocusNode,
                      icon: Icons.home_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16.h),

                    // Address Line 2
                    _buildTextField(
                      label: 'Address Line 2 (Road, Area, Colony)',
                      controller: _addressLine2Controller,
                      focusNode: _addressLine2FocusNode,
                      nextFocusNode: _cityFocusNode,
                      icon: Icons.location_on_outlined,
                      textInputAction: TextInputAction.next,
                    ),

                    SizedBox(height: 16.h),

                    // City and State
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'City',
                            controller: _cityController,
                            focusNode: _cityFocusNode,
                            nextFocusNode: _stateFocusNode,
                            icon: Icons.location_city_outlined,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter city';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildTextField(
                            label: 'State',
                            controller: _stateController,
                            focusNode: _stateFocusNode,
                            nextFocusNode: _pincodeFocusNode,
                            icon: Icons.map_outlined,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter state';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Pincode
                    _buildTextField(
                      label: 'Pincode',
                      controller: _pincodeController,
                      focusNode: _pincodeFocusNode,
                      icon: Icons.pin_drop_outlined,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter pincode';
                        }
                        if (value.length != 6) {
                          return 'Please enter valid pincode';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20.h),

                    // Set as default checkbox
                    _buildDefaultCheckbox(),

                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
          ),

          // Save Button
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildUseCurrentLocationButton() {
    return GestureDetector(
      onTap: _isLoadingLocation ? null : _handleUseCurrentLocation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isLoadingLocation
                ? [Colors.grey.shade300, Colors.grey.shade400]
                : [const Color(0xFF4ECDC4), const Color(0xFF44B3AA)],
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: _isLoadingLocation
                  ? Colors.grey.withValues(alpha: 0.2)
                  : const Color(0xFF4ECDC4).withValues(alpha: 0.3),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoadingLocation)
              SizedBox(
                width: 18.w,
                height: 18.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(Icons.my_location_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 10.w),
            Text(
              _isLoadingLocation
                  ? 'Detecting Location...'
                  : 'Use Current Location',
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
            text: 'Add New Address',
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: ['home', 'work', 'other'].map((type) {
        final isSelected = _selectedType == type;
        final displayName = type[0].toUpperCase() + type.substring(1);
        return Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedType = type;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF25A63E)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF25A63E)
                      : Colors.grey.shade300,
                  width: 1.5.w,
                ),
              ),
              child: Text(
                displayName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: (_) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20.sp, color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFF25A63E), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultCheckbox() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _setAsDefault = !_setAsDefault;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 22.w,
              height: 22.h,
              decoration: BoxDecoration(
                color: _setAsDefault
                    ? const Color(0xFF25A63E)
                    : Colors.transparent,
                border: Border.all(
                  color: _setAsDefault
                      ? const Color(0xFF25A63E)
                      : Colors.grey.shade400,
                  width: 2.w,
                ),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: _setAsDefault
                  ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                  : null,
            ),
            SizedBox(width: 12.w),
            Text(
              'Set as default address',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
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
        onTap: _isSaving ? null : _handleSaveAddress,
        child: Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: _isSaving ? Colors.grey.shade400 : const Color(0xFF25A63E),
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              if (!_isSaving)
                BoxShadow(
                  color: const Color(0xFF25A63E).withValues(alpha: 0.3),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                ),
            ],
          ),
          child: Center(
            child: _isSaving
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Save Address',
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
