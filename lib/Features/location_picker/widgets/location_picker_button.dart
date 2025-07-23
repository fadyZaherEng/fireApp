import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../constants/app_constants.dart';
import '../widgets/location_map_picker.dart';

class LocationPickerButton extends StatefulWidget {
  final String? selectedAddress;
  final double? latitude;
  final double? longitude;
  final Function(double latitude, double longitude, String? address)?
      onLocationSelected;
  final String? hintText;

  const LocationPickerButton({
    super.key,
    this.selectedAddress,
    this.latitude,
    this.longitude,
    this.onLocationSelected,
    this.hintText,
  });

  @override
  State<LocationPickerButton> createState() => _LocationPickerButtonState();
}

class _LocationPickerButtonState extends State<LocationPickerButton> {
  String? _currentAddress;
  double? _currentLatitude;
  double? _currentLongitude;

  AppLocalizations get _localizations => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _currentAddress = widget.selectedAddress;
    _currentLatitude = widget.latitude;
    _currentLongitude = widget.longitude;
  }

  @override
  void didUpdateWidget(LocationPickerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAddress != oldWidget.selectedAddress) {
      _currentAddress = widget.selectedAddress;
    }
    if (widget.latitude != oldWidget.latitude) {
      _currentLatitude = widget.latitude;
    }
    if (widget.longitude != oldWidget.longitude) {
      _currentLongitude = widget.longitude;
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationMapPicker(
          initialLatitude: _currentLatitude,
          initialLongitude: _currentLongitude,
          onLocationSelected: (latitude, longitude) {
            // Location selected callback - can be used by parent widgets
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _currentLatitude = result['latitude'];
        _currentLongitude = result['longitude'];
        _currentAddress = result['address'];
      });

      // Notify parent widget with the new coordinates
      if (_currentLatitude != null && _currentLongitude != null) {
        widget.onLocationSelected?.call(
          _currentLatitude!,
          _currentLongitude!,
          _currentAddress,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // Calculate dynamic height based on content
    final hasCoordinates = _currentAddress != null &&
        _currentLatitude != null &&
        _currentLongitude != null;
    final containerHeight = hasCoordinates ? 65.h : 50.h;

    return GestureDetector(
      onTap: _openLocationPicker,
      child: Container(
        constraints: BoxConstraints(
          minHeight: containerHeight,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.inputBorderColor,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.primaryRed,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _currentAddress != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentAddress!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blackTextColor,
                              fontFamily: isRTL ? 'Almarai' : 'Poppins',
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_currentLatitude != null &&
                              _currentLongitude != null) ...[
                            SizedBox(height: 2.h),
                            Text(
                              '${_currentLatitude!.toStringAsFixed(4)}, ${_currentLongitude!.toStringAsFixed(4)}',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
                                height: 1.0,
                              ),
                            ),
                          ],
                        ],
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.hintText ??
                              _localizations.translate('selectLocationFromMap'),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.hintTextColor,
                            fontFamily: isRTL ? 'Almarai' : 'Poppins',
                          ),
                        ),
                      ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.map,
                color: AppColors.primaryBlue,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Getters for accessing the current location data
  String? get selectedAddress => _currentAddress;
  double? get latitude => _currentLatitude;
  double? get longitude => _currentLongitude;
}
