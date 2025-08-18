# Chat Feature

This module implements a chat interface with support for text, image, and video messages. It includes proper permission handling for both Android and iOS platforms.

## Features

- Send and receive text messages
- Send and view images
- Send and play videos with thumbnail preview
- RTL support for Arabic language
- Permission handling for camera, gallery, and storage
- File size validation (10MB for images, 20MB for videos)
- Error handling and user feedback

## Permissions

### Android
Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### iOS
Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take photos and videos</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone to record videos with sound</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select photos and videos</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need access to your location for location-based features</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need access to your location for location-based features</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save photos and videos to your library</string>
```

## Dependencies

- `image_picker: ^1.0.7` - For picking images and videos from gallery/camera
- `video_player: ^2.8.1` - For playing videos in the chat
- `permission_handler: ^12.0.0+1` - For handling runtime permissions

## Usage

```dart
// Navigate to chat screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatScreen(
      providerId: '123',
      providerName: 'John Doe',
    ),
  ),
);
```

## Implementation Notes

1. The chat screen uses local data for demonstration purposes.
2. For production, you'll need to integrate with a backend service.
3. Images and videos are currently stored locally. Consider implementing cloud storage for a production app.
4. The UI is responsive and supports both light and dark themes.

## Known Issues

- Video thumbnails are not yet implemented.
- The chat does not currently support read receipts or typing indicators.
- Offline support is not implemented.

## Future Enhancements

1. Implement real-time messaging using WebSockets or Firebase.
2. Add support for audio messages.
3. Implement message status (sent, delivered, read).
4. Add support for file attachments.
5. Implement end-to-end encryption for privacy.
6. Add support for group chats.
