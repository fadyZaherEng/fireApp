import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  // Check and request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Check and request gallery/photos permission
  static Future<bool> requestPhotosPermission() async {
    if (await Permission.photos.isRestricted) {
      return false;
    }
    
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  // Check and request storage permission (for Android 12-)
  static Future<bool> requestStoragePermission() async {
    if (await Permission.storage.isRestricted) {
      return false;
    }
    
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // Check and request microphone permission (for video recording)
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Check and request location permission
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  // Check if we have all necessary media permissions
  static Future<bool> hasMediaPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final photosStatus = await Permission.photos.status;
    final storageStatus = await Permission.storage.status;
    
    return cameraStatus.isGranted && 
           (photosStatus.isGranted || storageStatus.isGranted);
  }

  // Open app settings for user to manually enable permissions
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  // Check if we can access media (photos/videos)
  static Future<bool> canAccessMedia() async {
    if (await Permission.photos.isRestricted) {
      return false;
    }
    
    final photosStatus = await Permission.photos.status;
    final storageStatus = await Permission.storage.status;
    
    return photosStatus.isGranted || storageStatus.isGranted;
  }

  // Request all necessary permissions for chat
  static Future<Map<Permission, PermissionStatus>> requestChatPermissions() async {
    final status = await [
      Permission.camera,
      Permission.photos,
      Permission.storage,
      Permission.microphone,
    ].request();
    
    return status;
  }
}
