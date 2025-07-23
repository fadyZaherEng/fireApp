// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:logger/logger.dart';

// class LocationService {
//   static final Logger _logger = Logger();

//   // Get current location coordinates
//   static Future<Map<String, double>?> getCurrentLocation() async {
//     try {
//       // Check location permission status
//       PermissionStatus permission = await Permission.location.status;

//       if (!permission.isGranted) {
//         // Request permission
//         final status = await Permission.location.request();
//         if (!status.isGranted) {
//           _logger.w('Location permission denied');
//           return _getDefaultLocation();
//         }
//       }

//       // Check if location services are enabled
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         _logger.w('Location services are disabled');
//         return _getDefaultLocation();
//       }

//       // Get current position
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.medium,
//         timeLimit: const Duration(seconds: 10),
//       );

//       _logger.i(
//           '✅ Current location obtained: ${position.latitude}, ${position.longitude}');

//       return {
//         'latitude': position.latitude,
//         'longitude': position.longitude,
//       };
//     } catch (e) {
//       _logger.e('💥 Error getting current location: $e');
//       return _getDefaultLocation();
//     }
//   }

//   // Default location (Riyadh, Saudi Arabia)
//   static Map<String, double> _getDefaultLocation() {
//     _logger.i('🏙️ Using default location (Riyadh)');
//     return {
//       'latitude': 24.7136,
//       'longitude': 46.6753,
//     };
//   }

//   // Check if location permissions are granted
//   static Future<bool> hasLocationPermission() async {
//     PermissionStatus permission = await Permission.location.status;
//     return permission.isGranted;
//   }
// }
