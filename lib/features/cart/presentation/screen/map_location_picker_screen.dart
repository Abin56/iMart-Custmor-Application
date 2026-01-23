import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Google Maps Location Picker Screen
/// Allows users to select their delivery address by picking location on map
class MapLocationPickerScreen extends StatefulWidget {
  const MapLocationPickerScreen({super.key});

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(19.0760, 72.8777); // Mumbai default
  bool _isLoadingLocation = true;
  bool _isLoadingAddress = false;
  String _currentAddress = 'Fetching address...';

  // Address components
  String? _streetAddress1;
  String? _streetAddress2;
  String? _city;
  String? _state;
  String? _postalCode;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// Get current GPS location
  Future<void> _getCurrentLocation() async {
    try {
      // Check location permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          // Permission denied - use default location
          setState(() {
            _isLoadingLocation = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Location permission denied'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
          await _getAddressFromLatLng(_currentPosition);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Location permissions are permanently denied',
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        await _getAddressFromLatLng(_currentPosition);
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      // Move camera to current location
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 16),
      );

      // Get address for current location
      await _getAddressFromLatLng(_currentPosition);
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      await _getAddressFromLatLng(_currentPosition);
    }
  }

  /// Reverse geocode - get address from coordinates
  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
      _currentAddress = 'Fetching address...';
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // Build address components
        _streetAddress1 = place.street ?? place.subThoroughfare;
        _streetAddress2 = place.subLocality ?? place.locality;
        _city = place.locality ?? place.subAdministrativeArea;
        _state = place.administrativeArea;
        _postalCode = place.postalCode;

        // Build display address
        final addressParts = [
          if (place.street?.isNotEmpty ?? false) place.street!,
          if (place.subLocality?.isNotEmpty ?? false) place.subLocality!,
          if (place.locality?.isNotEmpty ?? false) place.locality!,
          if (place.administrativeArea?.isNotEmpty ?? false)
            place.administrativeArea!,
          if (place.postalCode?.isNotEmpty ?? false) place.postalCode!,
        ];

        setState(() {
          _currentAddress = addressParts.isNotEmpty
              ? addressParts.join(', ')
              : 'Address not found';
          _isLoadingAddress = false;
        });
      } else {
        setState(() {
          _currentAddress = 'Address not found';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Unable to fetch address';
        _isLoadingAddress = false;
      });
    }
  }

  /// Handle map camera movement
  void _onCameraMove(CameraPosition position) {
    _currentPosition = position.target;
  }

  /// Handle map camera idle (user stopped dragging)
  void _onCameraIdle() {
    _getAddressFromLatLng(_currentPosition);
  }

  /// Confirm location selection and return to address form
  void _confirmLocation() {
    if (_currentAddress == 'Address not found' ||
        _currentAddress == 'Unable to fetch address' ||
        _currentAddress == 'Fetching address...') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a valid location'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'latitude': _currentPosition.latitude.toString(),
      'longitude': _currentPosition.longitude.toString(),
      'address1': _streetAddress1 ?? '',
      'address2': _streetAddress2 ?? '',
      'city': _city ?? '',
      'state': _state ?? '',
      'pincode': _postalCode ?? '',
      'fullAddress': _currentAddress,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 16,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Center marker pin
          Center(
            child: Icon(
              Icons.location_pin,
              size: 50.sp,
              color: const Color(0xFF25A63E),
            ),
          ),

          // Top header with back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10.h,
                left: 16.w,
                right: 16.w,
                bottom: 10.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.black,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Select Location',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom sheet with address and confirm button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, -2.h),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address display
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: const Color(0xFF25A63E),
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Location',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            if (_isLoadingAddress)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 16.w,
                                    height: 16.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF25A63E),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Fetching address...',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                _currentAddress,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  height: 1.4,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoadingAddress ? null : _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25A63E),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Confirm Location',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoadingLocation)
            ColoredBox(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF25A63E)),
                    SizedBox(height: 16.h),
                    Text(
                      'Getting your location...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
