// import 'package:dio/dio.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:hatif_mobile/core/notification/firebase_navigate.dart';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import '../common/styles/show_toast.dart';

// class FirebaseCloudMessaging {
//   factory FirebaseCloudMessaging() => _instance;

//   FirebaseCloudMessaging._();

//   static final FirebaseCloudMessaging _instance = FirebaseCloudMessaging._();

//   static const String subscribeKey = 'Enmaa';

//   final _firebaseMessaging = FirebaseMessaging.instance;

//   ValueNotifier<bool> isNotificationSubscribe = ValueNotifier(true);

//   bool isPermissionNotification = false;

//   Future<void> init() async {
//     //permission
//     await _permissionsNotification();

//     // forground
//     FirebaseMessaging.onMessage
//         .listen(FirebaseMessagingNavigate.forGroundHandler);

//     // terminated
//     await FirebaseMessaging.instance
//         .getInitialMessage()
//         .then(FirebaseMessagingNavigate.terminatedHandler);

//     // background
//     FirebaseMessaging.onMessageOpenedApp
//         .listen(FirebaseMessagingNavigate.backGroundHandler);
//   }

//   /// controller for the notification if user subscribe or unsubscribed
//   /// or accpeted the permission or not

//   Future<void> controllerForUserSubscribe(BuildContext context) async {
//     if (isPermissionNotification == false) {
//       await _permissionsNotification();
//     } else {
//       if (isNotificationSubscribe.value == false) {
//         await _subscribeNotification();
//         if (!context.mounted) return;
//         ShowToast.showToastSuccessTop(
//           message: "msg",
//           seconds: 2,
//         );
//       } else {
//         await _unSubscribeNotification();
//         if (!context.mounted) return;
//         ShowToast.showToastSuccessTop(
//           message: "msg",
//           seconds: 2,
//         );
//       }
//     }
//   }

//   /// permissions to notifications
//   Future<void> _permissionsNotification() async {
//     final settings = await _firebaseMessaging.requestPermission(badge: false);

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       /// subscribe to notifications topic
//       isPermissionNotification = true;
//       await _subscribeNotification();
//       debugPrint('🔔🔔 User accepted the notification permission');
//     } else {
//       isPermissionNotification = false;
//       isNotificationSubscribe.value = false;
//       debugPrint('🔕🔕 User not accepted the notification permission');
//     }
//   }

//   /// subscribe notification

//   Future<void> _subscribeNotification() async {
//     isNotificationSubscribe.value = true;
//     await FirebaseMessaging.instance.subscribeToTopic(subscribeKey);
//     debugPrint('====🔔 Notification Subscribed 🔔=====');
//   }

//   /// unsubscribe notification

//   Future<void> _unSubscribeNotification() async {
//     isNotificationSubscribe.value = false;
//     await FirebaseMessaging.instance.unsubscribeFromTopic(subscribeKey);
//     debugPrint('====🔕 Notification Unsubscribed 🔕=====');
//   }

// // send notifcation with api
//   Future<void> sendTopicNotification({
//     required String title,
//     required String body,
//     required String token,
//   }) async {
//     try {
//       final response = await Dio().post<dynamic>(
//         "https://fcm.googleapis.com/v1/projects/hatif-13de6/messages:send",
//         options: Options(
//           validateStatus: (_) => true,
//           contentType: Headers.jsonContentType,
//           responseType: ResponseType.json,
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer ${await getAccessToken()}',
//           },
//         ),
//         data: {
//           "message": {
//             "token": token,
//             "notification": {"title": title, "body": body},
//           }
//         },
//       );

//       debugPrint('Notification Created => ${response.data}');
//     } catch (e) {
//       debugPrint('Notification Error => $e');
//     }
//   }

//   Future<String> getAccessToken() async {
//     // Your client ID and client secret obtained from Google Cloud Console
//     final Map<String, dynamic> serviceAccountJson = {
//       "type": "service_account",
//       "project_id": "hatif-13de6",
//       "private_key_id": "87f03a0c3819550713ac6076631ae22da4198f9c",
//       "private_key":
//           "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDMIA2OCavMtxkL\nezBkZdT19EBzi5IX/NQszb/tVYcAXmPpx346WiBVKCzepiB9C7CQdREbKy3RNKKy\nffnkBv5JFl6mTQvE7pfme4sX/Qkq2GQsu+KPwdRFzGT/2zOHA41YaO3U7IrJx6b7\nySVAmpxSzHPF9kx7qltUoekMkP4zsI+UuemswlvJaNAYI5lJ1hu80qJVlnIgezzu\nq4eO/z94SK2VHLvi9KuI7yuZbStF6gnp+1FvXe10lWcx0eJL23eCen1oKiKZbqlC\nppnUf5ApAVhUGRl6zOasZvfKriugc5XSZIpzIHohdqxDhYIoZRjhljmOvIAZbEgO\nVkF95jPjAgMBAAECggEAHlLiq0ec2d1syeED6DOdMT6W9oifluhXKCLBUNjO+eCL\n14vBy5mzn5hHdiStbeDMhYvxPcfVLMo0ze8GA6Mq/SDmxa4WF1bZ160Mau9gVcOY\nuhvdRT2RCHTGn6Bo5V/t4a+Q0/v3MDufKbIQ0n9FcCLG+NElPTfVDTESWxdiaWYc\nhwoet93W6zNrkPMNj7EIz9noPW4ZVfNeB7hm/cgDnc1TrS57pz8HlwdRtlTRoFrt\n9hGz69vubtSnRxtXWLrw9MNLT895jiiS1po5yyT/ghu+AwGIUvDPUIsDSVi0ijXd\nTcq9WT1V9hR0HKJ9S4hEt8anniBoKE+cD9jsMwVcpQKBgQD9u8/ZNzkMIrwMzCj4\n83Jk9UvdEuhgZ3Iz9zGQHNJb6sEN12eXQOHnYwwyqHcbiPf19MGUL4NU75sYTKF2\nRMYq90kMSUtbGIL1DtaZF/Q2kQNmI16cQQO41S1cma0qK4S5hNcTyyeHVVzOntpF\nkh/ixov8Fl/c84AW6KGCeN7jbwKBgQDN8s5mY+m/dqbnwfkUO7qHqrXmuGM9rEXO\niIuswXU15Rej4dmHydfukqS+iFalqBjOVY0y2JlLT8JzgPEyo0ZAEyAV4UEhC+FH\nNyDaUJEMKXt10sxuUl9HkKr/We+kHhNf6GMluwo7WuerMLhZy5yYTTxCeM3IyZu8\n+XPeC10szQKBgQDiSqs/jam6MgxG2Zo9FVnTwpVrUF6hBAFtaSvx3FKcGY0d3BuO\nYRZYeBS75VV84DZNTIGMuKdHi/5luIpT4Vhfn3WtmHy1fPHmvtoTZbKvK7u9TxQl\nBTLdmHpBWOmAb5mKn3f2NjxFzZLcz/3ZCE6ZwPu90vKiKyT0yXqp00TtzwKBgCL0\nKcnA/WQsjClbh53CgWcTNypAcz99ZJ+oFySr9Ou/xSJga54bSNXJ98IKu8ID5Kno\nZT2S+3mHwPX/lXBFu9+WH2T3RSmJraN7nMzQzb1lsPmPXHkA7ADmcc9DAWQ2Yo1t\nkJ5Pv23RgO5SJ4e+AgbrXOXfQPXqGc+Z+utdvGOlAoGBAJOYHSxfHQDpCUQ2CTYL\nHSEgdyvbkFJTds3DFTDMoFRNVNGgcQ6bqL2yuYHE5Mms00CH/NsjsxgXHpq3QQJ2\nU1Gc1NjDJStBsdSkKBkH/vkteEhAztNE6Qz1uIeC61QL44fJTWlaIDk8vXHz0APQ\nxBYxHBub40myzD9iLiiuv2iP\n-----END PRIVATE KEY-----\n",
//       "client_email":
//           "firebase-adminsdk-fbsvc@hatif-13de6.iam.gserviceaccount.com",
//       "client_id": "105092592676493505368",
//       "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//       "token_uri": "https://oauth2.googleapis.com/token",
//       "auth_provider_x509_cert_url":
//           "https://www.googleapis.com/oauth2/v1/certs",
//       "client_x509_cert_url":
//           "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40hatif-13de6.iam.gserviceaccount.com",
//       "universe_domain": "googleapis.com"
//     };

//     List<String> scopes = [
//       "https://www.googleapis.com/auth/userinfo.email",
//       "https://www.googleapis.com/auth/firebase.database",
//       "https://www.googleapis.com/auth/firebase.messaging"
//     ];

//     http.Client client = await auth.clientViaServiceAccount(
//       auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
//       scopes,
//     );

//     // Obtain the access token
//     auth.AccessCredentials credentials =
//         await auth.obtainAccessCredentialsViaServiceAccount(
//             auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
//             scopes,
//             client);

//     // Close the HTTP client
//     client.close();

//     // Return the access token
//     return credentials.accessToken.data;
//   }
// }
