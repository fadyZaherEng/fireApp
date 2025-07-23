import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';

class LocationMapPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double latitude, double longitude)? onLocationSelected;

  const LocationMapPicker({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.onLocationSelected,
  });

  @override
  State<LocationMapPicker> createState() => _LocationMapPickerState();
}

class _LocationMapPickerState extends State<LocationMapPicker> {
  MapController? _mapController;
  LatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isLoading = false;
  bool _isGettingCurrentLocation = false;

  AppLocalizations get _localizations => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation =
          LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _getAddressFromCoordinates(
          widget.initialLatitude!, widget.initialLongitude!);
    } else {
      // Check if we have permission to get current location
      final permissionStatus = await Permission.location.status;

      if (permissionStatus.isGranted) {
        // Try to get current location first
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 5),
          );
          setState(() {
            _selectedLocation = LatLng(position.latitude, position.longitude);
          });
          _getAddressFromCoordinates(position.latitude, position.longitude);
          return;
        } catch (e) {
          // If getting current location fails, fall back to default
        }
      }

      // Default to Riyadh, Saudi Arabia
      _selectedLocation = const LatLng(24.7136, 46.6753);
      _getAddressFromCoordinates(24.7136, 46.6753);
    }
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _isGettingCurrentLocation = true);

    try {
      // First check current permission status
      PermissionStatus permission = await Permission.location.status;

      if (permission.isGranted) {
        await _getCurrentLocation();
        return;
      }

      // If not granted, request permission
      final status = await Permission.location.request();

      if (status.isGranted) {
        await _getCurrentLocation();
      } else if (status.isDenied) {
        _showPermissionDialog();
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog();
      } else if (status.isRestricted) {
        _showErrorSnackBar(_localizations.translate('locationRestrictedError'));
      }
    } catch (e) {
      _showErrorSnackBar(_localizations.translate('locationPermissionError'));
    } finally {
      setState(() => _isGettingCurrentLocation = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = newLocation;
      });

      // Move camera to current location
      if (_mapController != null) {
        _mapController!.move(newLocation, 16);
      }

      _getAddressFromCoordinates(position.latitude, position.longitude);

      _showSuccessSnackBar(_localizations.translate('currentLocationObtained'));
    } catch (e) {
      _showErrorSnackBar(
          _localizations.translate('failedToGetCurrentLocation'));
    }
  }

  void _showPermissionDialog() {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Row(
          children: [
            Icon(
              Icons.location_on,
              color: AppColors.primaryBlue,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                _localizations.translate('locationPermissionRequired'),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: isRTL ? 'Almarai' : 'Poppins',
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _localizations.translate('locationPermissionMessage'),
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
                color: AppColors.blackTextColor,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primaryBlue,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _localizations.translate('locationPermissionBenefit'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: isRTL ? 'Almarai' : 'Poppins',
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _localizations.translate('notNow'),
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _requestLocationPermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              _localizations.translate('allowLocation'),
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Row(
          children: [
            Icon(
              Icons.settings,
              color: AppColors.primaryRed,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                _localizations.translate('locationPermissionDenied'),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: isRTL ? 'Almarai' : 'Poppins',
                  color: AppColors.primaryRed,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _localizations.translate('openSettingsMessage'),
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
                color: AppColors.blackTextColor,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.primaryRed,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _localizations.translate('settingsInstructions'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: isRTL ? 'Almarai' : 'Poppins',
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _localizations.translate('skipForNow'),
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              _localizations.translate('openSettings'),
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    setState(() => _isLoading = true);

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        setState(() {
          _selectedAddress =
              '${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.country ?? ''}';
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = '$latitude, $longitude';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _selectedAddress = null;
    });
    _getAddressFromCoordinates(location.latitude, location.longitude);
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      // Call the callback function if provided
      widget.onLocationSelected?.call(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      );

      Navigator.pop(context, {
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'address': _selectedAddress,
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontFamily: Directionality.of(context) == TextDirection.rtl
                ? 'Almarai'
                : 'Poppins',
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontFamily: Directionality.of(context) == TextDirection.rtl
                ? 'Almarai'
                : 'Poppins',
          ),
        ),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        title: Text(
          _localizations.translate('selectLocation'),
          style: TextStyle(
            fontFamily: isRTL ? 'Almarai' : 'Poppins',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _selectedLocation != null ? _confirmLocation : null,
            child: Text(
              _localizations.translate('confirm'),
              style: TextStyle(
                color: Colors.white,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Flutter Map
          if (_selectedLocation != null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation!,
                initialZoom: 15,
                onTap: (tapPosition, point) => _onMapTapped(point),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.safety_zone_consumer',
                  maxZoom: 19,
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _selectedLocation != null
                      ? [
                          Marker(
                            point: _selectedLocation!,
                            width: 60.w,
                            height: 60.h,
                            child: GestureDetector(
                              onTap: () {
                                if (_selectedAddress != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _selectedAddress!,
                                        style: TextStyle(
                                          fontFamily:
                                              isRTL ? 'Almarai' : 'Poppins',
                                        ),
                                      ),
                                      backgroundColor: AppColors.primaryBlue,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed,
                                  borderRadius: BorderRadius.circular(30.r),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 30.sp,
                                ),
                              ),
                            ),
                          ),
                        ]
                      : [],
                ),
              ],
            ),

          // Tap to select location hint
          if (_selectedAddress == null)
            Positioned(
              top: 20.h,
              left: 16.w,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _localizations.translate('tapToSelectLocation'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: isRTL ? 'Almarai' : 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Current location button
          Positioned(
            bottom: _selectedAddress != null ? 150.h : 80.h,
            right: 16.w,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: _isGettingCurrentLocation
                      ? null
                      : _requestLocationPermission,
                  child: Container(
                    width: 56.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: _isGettingCurrentLocation
                        ? SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryBlue),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.my_location,
                            color: AppColors.primaryBlue,
                            size: 24.sp,
                          ),
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryBlue),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _localizations.translate('gettingAddress'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: isRTL ? 'Almarai' : 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Address display card
          if (_selectedAddress != null)
            Positioned(
              bottom: 20.h,
              left: 16.w,
              right: 16.w,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.primaryRed,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _localizations.translate('selectedAddress'),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: isRTL ? 'Almarai' : 'Poppins',
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _selectedAddress!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: isRTL ? 'Almarai' : 'Poppins',
                          color: AppColors.blackTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_selectedLocation != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontFamily: 'Poppins',
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
