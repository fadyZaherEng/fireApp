// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:hatif_mobile/main.dart';
// import 'package:sip_ua/sip_ua.dart';

// class LocalNotificationService extends SipUaHelperListener {
//   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static const String channelId = 'sip_registration_status';
//   static const String callChannelId = 'sip_call_status';
//   static const int notificationId = 1;
//   static const int callNotificationId = 2;

//   static final LocalNotificationService _instance = LocalNotificationService();
//   Timer? _notificationTimer;

//   static Future<void> init() async {
//     const settings = InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//       iOS: DarwinInitializationSettings(),
//     );
//     await flutterLocalNotificationsPlugin.initialize(
//       settings,
//       onDidReceiveNotificationResponse: onTap,
//     );

//     // Start a timer to periodically check and re-show the notification
//     // _instance._startNotificationTimer();
//   }

//   static void onTap(NotificationResponse notificationResponse) {
//     // Handle notification tap if needed
//   }

//   void _startNotificationTimer() {
//     _notificationTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
//       // Re-show the notification with the latest state
//     });
//   }

//   Color _getNotificationColor(RegistrationStateEnum state) {
//     switch (state) {
//       case RegistrationStateEnum.REGISTERED:
//         return Colors.green; // Green for registered
//       case RegistrationStateEnum.UNREGISTERED:
//         return Colors.red; // Red for unregistered
//       case RegistrationStateEnum.REGISTRATION_FAILED:
//         return Colors.orange; // Orange for registration failed
//       default:
//         return Colors.grey; // Grey for unknown state
//     }
//   }

//   static Future<void> updateNotification(
//       String title, String body, Color color) async {
//     final notificationDetails = NotificationDetails(
//       android: AndroidNotificationDetails(
//         channelId,
//         'SIP Registration Status',
//         importance: Importance.low,
//         priority: Priority.low,
//         ongoing: true,
//         autoCancel: false,
//         enableVibration: false,
//         enableLights: false,
//         color: color, // Set the notification color
//         category: AndroidNotificationCategory.call,
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       ),
//     );
//     await flutterLocalNotificationsPlugin.show(
//       notificationId,
//       title,
//       body,
//       notificationDetails,
//     );
//   }

//   static Future<void> showCallNotification(Call call) async {
//     final String callerInfo = call.remote_identity ?? 'Unknown Caller';
//     final notificationDetails = NotificationDetails(
//       android: AndroidNotificationDetails(
//         callChannelId,
//         'Active Call',
//         importance: Importance.high,
//         priority: Priority.high,
//         ongoing: true,
//         autoCancel: false,
//         enableVibration: true,
//         enableLights: true,
//         color: Colors.green,
//         category: AndroidNotificationCategory.call,
//         timeoutAfter: null,
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//         interruptionLevel: InterruptionLevel.timeSensitive,
//       ),
//     );

//     await flutterLocalNotificationsPlugin.show(
//       callNotificationId,
//       'Active Call',
//       'In call with $callerInfo',
//       notificationDetails,
//     );
//   }

//   static Future<void> dismissCallNotification() async {
//     await flutterLocalNotificationsPlugin.cancel(callNotificationId);
//   }

//   @override
//   void callStateChanged(Call call, CallState state) {
//     // Show notification when call is confirmed (connected)
//     if (state.state == CallStateEnum.CONFIRMED) {
//       //showCallNotification(call);
//     }
//     // Remove the notification when call ends
//     else if (state.state == CallStateEnum.ENDED ||
//         state.state == CallStateEnum.FAILED) {
//       dismissCallNotification();
//     }
//   }

//   @override
//   void onNewMessage(SIPMessageRequest msg) {
//     // Handle new messages if needed
//   }

//   @override
//   void onNewNotify(Notify ntf) {
//     // Handle new notifies if needed
//   }

//   @override
//   void onNewReinvite(ReInvite event) {
//     // Handle new reinvites if needed
//   }

//   @override
//   void registrationStateChanged(RegistrationState state) {
//     if (state.state != null) {
//       // updateNotification(
//       //   "Registration State",
//       //   state.state!.name.toLowerCase(),
//       //   _getNotificationColor(state.state!),
//       // );
//     }
//   }

//   @override
//   void transportStateChanged(TransportState state) {
//     // Handle transport state changes if needed
//   }

//   void dispose() {
//     _notificationTimer?.cancel();
//   }
// }
