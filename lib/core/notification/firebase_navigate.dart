// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:flutter_callkit_incoming/entities/notification_params.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

// class FirebaseMessagingNavigate {
//   // forground
//   static Future<void> forGroundHandler(RemoteMessage? message) async {
//     if (message != null) {
//       // await LocalNotificationService.showSimpleNotification(
//       //   title: message.notification!.title ?? '',
//       //   body: message.notification!.body ?? '',
//       //   payload: message.data['productId'].toString(),
//       // );
//     }
//   }

//   // background
//   static void backGroundHandler(RemoteMessage? message) {
//     if (message != null) {
//       _navigate(message);
//     }
//   }

//   // terminated
//   static void terminatedHandler(RemoteMessage? message) {
//     if (message != null) {
//       _navigate(message);
//     }
//   }

//   static void _navigate(RemoteMessage message) {
//     if (int.parse(message.data['productId'].toString()) == -1) return;
//     // sl<GlobalKey<NavigatorState>>().currentState!.context.pushName(
//     //       AppRoutes.productDetails,
//     //       arguments: int.parse(message.data['productId'].toString()),
//     //     );
//   }
// }

// Future<void> showIncomingCalls(id, name, num) async {
//   final params = CallKitParams(
//       id: id,
//       nameCaller: name,
//       appName: 'Hatif',
//       handle: num,
//       avatar:
//           'https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png',
//       type: 0,
//       duration: 30000,
//       textAccept: 'Accept',
//       textDecline: 'Decline',
//       missedCallNotification:
//           NotificationParams(showNotification: true, isShowCallback: false));

//   await FlutterCallkitIncoming.showCallkitIncoming(params);
// }
