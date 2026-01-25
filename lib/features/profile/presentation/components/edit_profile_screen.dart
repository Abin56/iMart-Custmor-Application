import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:imart/features/profile/application/providers/profile_provider.dart';
import 'package:imart/features/profile/application/states/profile_state.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../../../app/theme/colors.dart';

/// Edit Profile Screen
/// Allows users to edit their profile information
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isUploadingImage = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

    // Load current profile data
    _loadProfileData();
  }

  void _loadProfileData() {
    final profileState = ref.read(profileProvider);
    if (profileState is ProfileLoaded) {
      final user = profileState.user;
      _nameController.text = '${user.firstName} ${user.lastName}'.trim();
      _phoneController.text = user.phoneNumber;
      _emailController.text = user.email;
    } else if (profileState is ProfileUpdated) {
      final user = profileState.user;
      _nameController.text = '${user.firstName} ${user.lastName}'.trim();
      _phoneController.text = user.phoneNumber;
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Show bottom sheet to choose image source
  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16.h),
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Choose Profile Photo',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20.h),
              // Camera option
              _buildImageSourceOption(
                icon: Icons.camera_alt,
                title: 'Take Photo',
                subtitle: 'Use camera to capture',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              Divider(height: 1.h, color: Colors.grey.shade200),
              // Gallery option
              _buildImageSourceOption(
                icon: Icons.photo_library,
                title: 'Choose from Gallery',
                subtitle: 'Select from your photos',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null) ...[
                Divider(height: 1.h, color: Colors.grey.shade200),
                // Remove photo option
                _buildImageSourceOption(
                  icon: Icons.delete_outline,
                  title: 'Remove Photo',
                  subtitle: 'Remove current photo',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                  iconColor: Colors.red,
                ),
              ],
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: (iconColor ?? const Color(0xFF25A63E)).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: iconColor ?? const Color(0xFF25A63E),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  /// Request permission for camera or gallery
  Future<bool> _requestPermission(ImageSource source) async {
    Permission permission;

    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      // For Android 13+ (API 33+), use photos permission
      if (Platform.isAndroid) {
        permission = Permission.photos;
      } else {
        permission = Permission.photos;
      }
    }

    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      // Show dialog to open settings
      if (mounted) {
        await _showPermissionSettingsDialog(source);
      }
      return false;
    }

    return false;
  }

  /// Show dialog to open app settings
  Future<void> _showPermissionSettingsDialog(ImageSource source) async {
    final permissionName = source == ImageSource.camera ? 'Camera' : 'Photo Library';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Permission Required',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        content: Text(
          '$permissionName permission is required to upload profile photo. Please enable it in app settings.',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(
              'Open Settings',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF25A63E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permission first
      final hasPermission = await _requestPermission(source);

      if (!hasPermission) {
        return;
      }

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  const Text('Photo selected successfully'),
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
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
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

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      // Parse name into first and last name
      final fullName = _nameController.text.trim();
      final nameParts = fullName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : fullName;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : null;

      // Show uploading state if image is selected
      if (_selectedImage != null) {
        setState(() {
          _isUploadingImage = true;
        });
      }

      // Call profile provider to update profile
      await ref
          .read(profileProvider.notifier)
          .updateProfile(
            firstName: firstName,
            lastName: lastName,
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            profilePhoto: _selectedImage,
          );

      // Listen to profile state
      final profileState = ref.read(profileProvider);

      // Reset uploading state
      if (mounted && _isUploadingImage) {
        setState(() {
          _isUploadingImage = false;
        });
      }

      if (mounted) {
        if (profileState is ProfileUpdated || profileState is ProfileLoaded) {
          // Show success snackbar
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
                          'Profile updated successfully',
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
        } else if (profileState is ProfileError) {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(profileState.failure.message),
              backgroundColor: Colors.red,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 24.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Image with edit icon
                        _buildProfileImage(),

                        SizedBox(height: 32.h),

                        // Name field
                        _buildFieldLabel('Name'),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'Enter your name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 20.h),

                        // Phone field
                        _buildFieldLabel('Phone'),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _phoneController,
                          hintText: 'Enter your phone number',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 20.h),

                        // Email field
                        _buildFieldLabel('Mail'),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

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
            text: 'Edit Profile',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          // Profile image with gradient border
          Container(
            width: 110.w,
            height: 110.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF25A63E), Color(0xFF0D5C2E)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF25A63E).withValues(alpha: 0.3),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: ClipOval(
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.asset(
                            'assets/images/no-image.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF25A63E)
                                          .withValues(alpha: 0.1),
                                      const Color(0xFF0D5C2E)
                                          .withValues(alpha: 0.1),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 50.sp,
                                  color: const Color(0xFF0D5C2E),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
          ),

          // Edit icon overlay with gradient
          Positioned(
            right: 4.w,
            bottom: 4.h,
            child: GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF25A63E), Color(0xFF1B7A43)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3.w),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF25A63E).withValues(alpha: 0.4),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Icon(Icons.camera_alt, size: 18.sp, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0D5C2E),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Row(
      children: [
        // Text field with shadow
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
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
                filled: true,
                fillColor: const Color(0xFFD3D3D3), // Light gray background
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 18.w,
                  vertical: 16.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none, // No border
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none, // No border
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none, // No border even when focused
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: Colors.red.shade400,
                    width: 2.w,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: Colors.red.shade400,
                    width: 2.w,
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 14.w),

        // Edit icon with circular background
        Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF25A63E).withValues(alpha: 0.1),
                const Color(0xFF1B7A43).withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF25A63E).withValues(alpha: 0.3),
              width: 1.5.w,
            ),
          ),
          child: Icon(
            Icons.edit_outlined,
            size: 18.sp,
            color: const Color(0xFF25A63E),
          ),
        ),
      ],
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
            Icon(Icons.check_circle_outline, color: Colors.white, size: 24.sp),
            SizedBox(width: 10.w),
            Text(
              'Save Changes',
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
