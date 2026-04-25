// import 'package:eshop_multivendor/Screen/PushNotification/PushNotificationService.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// class FirebaseNotificationManager {
//   final Future<void> Function(RemoteMessage message)? foregroundMessageHandler;
//   final void Function(Map<String, dynamic> payload)? onTapNotification;
//   FirebaseNotificationManager({
//     this.foregroundMessageHandler,
//     this.onTapNotification,
//   });

//   Future<void> init() async {
//     FirebaseMessaging.onBackgroundMessage(
//         PushNotificationService.backgroundNotification);

//     RemoteMessage? value = await FirebaseMessaging.instance.getInitialMessage();
//     if (value != null) {
//       onTapNotification?.call(value.data);
//     }
//     FirebaseMessaging.onMessage.listen((RemoteMessage event) {
//       print("message ---->${event}");
//       foregroundMessageHandler?.call(event);
//     });

//     //This will listen onTap so we are making it external function so we can manage taps from one method of awesome and local notification
//     FirebaseMessaging.onMessageOpenedApp
//         .listen((event) => onTapNotification?.call(event.data));
//   }
// }

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:eshop_multivendor/Screen/PushNotification/PushNotificationService.dart';

class FirebaseNotificationManager {
  final Future<void> Function(RemoteMessage message)? foregroundMessageHandler;
  final void Function(Map<String, dynamic> payload)? onTapNotification;

  // 🔧 Added to fix the lookup error
  int callCount = 0;

  FirebaseNotificationManager({
    this.foregroundMessageHandler,
    this.onTapNotification,
  });

  Future<void> init() async {
    // Background message handler
    FirebaseMessaging.onBackgroundMessage(
      
      PushNotificationService.backgroundNotification,
    );

    // Handle if app was launched from a terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      onTapNotification?.call(initialMessage.data);
    }

    // Foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      // 🔢 Increment call count each time a message is received
      callCount++;
      // Delegate to external handler if provided
      foregroundMessageHandler?.call(event);
    });

    // Tap on notification (when app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) {
      onTapNotification?.call(event.data);
    });
  }
}
