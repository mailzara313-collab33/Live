// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/routes.dart';
import 'package:eshop_multivendor/Model/personalChatHistory.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Dashboard/Dashboard.dart';
import 'package:eshop_multivendor/Screen/PushNotification/firebase_notificaiton.dart';
import 'package:eshop_multivendor/cubits/personalConverstationsCubit.dart';
import 'package:eshop_multivendor/repository/NotificationRepository.dart';
import 'package:eshop_multivendor/repository/hasUnreadChatRepository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:eshop_multivendor/Model/message.dart' as msg;

import '../../Helper/String.dart';
import '../../Provider/chatProvider.dart';
import '../../Provider/pushNotificationProvider.dart';

class PushNotificationService {
  static const String generalNotificationChannel = 'general_channel';
  static const String chatNotificationChannel = 'chat_channel';
  static const String imageNotificationChannel = 'image_channel';
  PushNotificationService();
  static late BuildContext context;

  static bool initialized = false;

  static final List<NotificationPermission> _requiredPermissionGroup = [
    NotificationPermission.Alert,
    NotificationPermission.Sound,
    NotificationPermission.Badge,
    NotificationPermission.Vibration,
    NotificationPermission.Light,
  ];

  static final FirebaseNotificationManager _firebaseNotificationManager =
      FirebaseNotificationManager(
        foregroundMessageHandler: foregroundNotification,
        onTapNotification: onTapNotification,
      );
  static final AwesomeNotifications notification = AwesomeNotifications();

  static void setDeviceToken({
    bool clearSessionToken = false,
    SettingProvider? settingProvider,
  }) {
    if (clearSessionToken) {
      settingProvider ??= Provider.of<SettingProvider>(context, listen: false);
      settingProvider.setPrefrence(FCMTOKEN, '');
    }
    FirebaseMessaging.instance.getToken().then((token) async {
      context.read<PushNotificationProvider>().registerToken(token, context);
    });
  }

  static void init() async {
    print('====init of firebase');
    if (initialized) {
      return;
    }
    // FirebaseNotificationManager.backgroundMessageHandler = handleNotification;
    await _firebaseNotificationManager.init();
    await requestPermission();
    _initializeNotificationChannels();
    notification.setListeners(
      onActionReceivedMethod: _awesomeNotificationTapListener,
    );

    // FirebaseMessaging.onMessage.listen(foregroundNotification);
    // FirebaseMessaging.onBackgroundMessage(backgroundNotification);

    // FirebaseMessaging.onMessageOpenedApp.listen((remoteMessage) {
    //   onMessageOpenedAppListener(remoteMessage);
    // });
    initialized = true;
    setDeviceToken();
  }

  static void onMessageOpenedAppListener(RemoteMessage remoteMessage) {
    onTapNotification(remoteMessage.data);
  }

  static void _initializeNotificationChannels() {
    notification.initialize('resource://mipmap/notification', [
      NotificationChannel(
        channelKey: generalNotificationChannel,
        channelName: 'General notifications',
        channelDescription: 'General channel to display notifications',
        importance: NotificationImportance.Max,
        playSound: true,
      ),
      NotificationChannel(
        channelKey: chatNotificationChannel,
        channelName: 'Chat Notifications',
        channelDescription: 'To display chat notification',
        importance: NotificationImportance.Max,
        playSound: true,
      ),
      NotificationChannel(
        channelKey: imageNotificationChannel,
        channelName: 'Image Notifications',
        channelDescription: 'To display images as notifications',
        importance: NotificationImportance.Max,
        playSound: true,
      ),
    ]);
  }

  @pragma("vm:entry-point")
  static Future<void> _awesomeNotificationTapListener(
    ReceivedAction action,
  ) async {
    log('Action is a $action');
    if (Platform.isIOS) {
      return;
    }
    onTapNotification(action.payload ?? {});
  }

  static Future<void> requestPermission() async {
    final NotificationSettings notificationSettings = await FirebaseMessaging
        .instance
        .getNotificationSettings();

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      await FirebaseMessaging.instance.requestPermission();

      if (notificationSettings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          notificationSettings.authorizationStatus ==
              AuthorizationStatus.provisional) {}
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      return;
    }
  }

  // static Future<void> requestPermission() async {
  //   final NotificationSettings settings =
  //       await FirebaseMessaging.instance.getNotificationSettings();

  //   if (settings.authorizationStatus != AuthorizationStatus.authorized) {
  //     await notification.requestPermissionToSendNotifications(
  //         channelKey: generalNotificationChannel,
  //         permissions: _requiredPermissionGroup);
  //     await notification.requestPermissionToSendNotifications(
  //         channelKey: chatNotificationChannel,
  //         permissions: _requiredPermissionGroup);
  //     await notification.requestPermissionToSendNotifications(
  //         channelKey: imageNotificationChannel,
  //         permissions: _requiredPermissionGroup);
  //   }
  // }

  static Future<void> createGeneralNotification({
    String? title,
    String? body,
    Map<String, String>? payload,
  }) async {
    if (!Platform.isIOS) {
      await notification.createNotification(
        content: NotificationContent(
          id: 0,
          channelKey: generalNotificationChannel,
          title: title,
          body: body,
          payload: payload ?? {},
          wakeUpScreen: true,
        ),
      );
    }
  }

  static Future<void> createImageNotification({
    String? title,
    String? body,
    Map<String, String>? payload,
  }) async {
    if (!Platform.isIOS) {
      await notification.createNotification(
        content: NotificationContent(
          id: 0,
          channelKey: imageNotificationChannel,
          title: title,
          body: body,
          wakeUpScreen: true,
          largeIcon: payload?['image'],
          hideLargeIconOnExpand: true,
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture: payload?['image'],
          payload: payload,
        ),
      );
    }
  }

  static Future<void> createChatNotification({
    String? title,
    String? body,
    Map<String, String>? payload,
  }) async {
    if (!Platform.isIOS) {
      await notification.createNotification(
        content: NotificationContent(
          id: 0,
          channelKey: chatNotificationChannel,
          title: title,
          body: body,
          wakeUpScreen: true,
          largeIcon: payload?['image'],
          hideLargeIconOnExpand: true,
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture: payload?['image'],
          payload: payload,
        ),
      );
    }
  }

  static Future<void> foregroundNotification(RemoteMessage notification) async {
    // print(
    // "notification message---->${notification.data}---->${notification.notification}");
    handleNotification(notification);
  }

  @pragma("vm:entry-point")
  static Future<void> backgroundNotification(RemoteMessage notification) async {
    // await Firebase.initializeApp();
    // handleNotification(notification);
    handleBackgroundMessage(notification);
    setPrefrenceBool(ISFROMBACK, true);
    if (notification.data['type'].toString() == 'chat') {
      HasUnreadChatRepository.setChatUnread(true);
      final messages = jsonDecode(notification.data['message']) as List;
      NotificationRepository.addChatNotification(
        message: jsonEncode(messages.first),
      );
    }
  }

  static Future<void> handleNotification(RemoteMessage notification) async {
    var image = notification.data['image'];
    UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    var data = notification.data;
    var title = data['title']?.toString() ?? '';
    var body = data['body']?.toString() ?? '';
    // var image = notification.data['image'] ?? '';
    var type = notification.data['type'] ?? '';
    var id = notification.data['type_id'] ?? '';

    // print('Hey i am notifiacation');
    // print('$link');

    if (type == 'chat') {
      final messages = jsonDecode(notification.data['message']) as List;

      if (converstationScreenStateKey.currentState?.mounted ?? false) {
        final state = converstationScreenStateKey.currentState!;

        if (messages.isNotEmpty) {
          print('No-not Empty');

          if (state.widget.personalChatHistory?.getOtherUserId() !=
              messages.first['from_id']) {
            HasUnreadChatRepository.setChatUnread(true);
            createChatNotification(
              title: title,
              body: body,
              payload: Map.from(notification.data),
            );

            context
                .read<PersonalConverstationsCubit>()
                .updateUnreadMessageCounter(
                  userId: messages.first['from_id'].toString(),
                );
          } else {
            state.addMessage(
              message: msg.Message.fromJson(Map.from(messages.first)),
            );
          }
        }
      } else {
        HasUnreadChatRepository.setChatUnread(true);
        //senders_name
        createChatNotification(
          title: title,
          body: body,
          payload: Map<String, String>.from(notification.data),
        );

        //Update the unread message counter
        if (messages.isNotEmpty) {
          if (messages.first['type'] == 'person') {
            context
                .read<PersonalConverstationsCubit>()
                .updateUnreadMessageCounter(
                  userId: messages.first['from_id'].toString(),
                );
          } else {}
        }
      }
    } else if (type == 'ticket_status') {
      Routes.navigateToCustomerSupportScreen(context);
    } else if (type == 'ticket_message') {
      if (CUR_TICK_ID == id &&
          context.read<ChatProvider>().chatstreamdata != null) {
        var parsedJson = json.decode(notification.data['chat']);
        parsedJson = parsedJson[0];
        Map<String, dynamic> sendata = {
          'id': parsedJson[ID],
          'title': parsedJson[TITLE],
          'message': parsedJson[MESSAGE],
          'user_id': parsedJson[USER_ID],
          'name': parsedJson[NAME],
          'date_created': parsedJson[DATE_CREATED],
          'attachments': parsedJson['attachments'],
        };
        var chat = {'data': sendata};
        if (parsedJson[USER_ID] != userProvider.userId) {
          context.read<ChatProvider>().chatstreamdata!.sink.add(
            jsonEncode(chat),
          );
        }
      }
    } else if (image != null && image != 'null' && image != '') {
      createImageNotification(
        body: notification.data['body'],
        title: notification.data['title'],
        payload: Map<String, String>.from(notification.data),
      );
      return;
    }
    if (type == 'chat') {
      if (converstationScreenStateKey.currentState?.mounted ?? true) {
        return;
      }
    }
    createGeneralNotification(
      title: notification.data['title'],
      body: notification.data['body'],
      payload: Map<String, String>.from(notification.data),
    );
  }

  static void onTapNotification(Map<String, dynamic> data) async {
    if ((data['type'] ?? '') == 'chat') {
      _onTapChatNotification(message: data);
    } else {
      _navigation(Map<String, String>.from(data));
      setPrefrenceBool(ISFROMBACK, false);
    }
  }

  static void handleBackgroundMessage(RemoteMessage notification) {
    print('notification data ----> ${notification.data}');
    var image = notification.data['image'] ?? '';
    if (image != null && image != 'null' && image != '') {
      createImageNotification(
        body: notification.data['body'],
        title: notification.data['title'],
        payload: Map<String, String>.from(notification.data),
      );
    } else {
      createGeneralNotification(
        title: notification.data['title'],
        body: notification.data['body'],
        payload: Map<String, String>.from(notification.data),
      );
    }
  }

  static void _onTapChatNotification({required Map<String, dynamic> message}) {
    if ((converstationScreenStateKey.currentState?.mounted) ?? false) {
      Navigator.of(context).pop();
    }

    final messages = jsonDecode(message['message']) as List;
    print('No-not group $messages');
    if (messages.isEmpty) {
      return;
    }

    final messageDetails = msg.Message.fromJson(
      jsonDecode(json.encode(messages.first)),
    );
    Routes.navigateToConverstationScreen(
      context: context,
      isGroup: false,
      personalChatHistory: PersonalChatHistory(
        unreadMsg: '1',
        opponentUserId: messageDetails.fromId,
        opponentUsername: messageDetails.sendersName,
        image: messageDetails.picture,
      ),
    );
  }

  static Future<void> _navigation(Map<String, String> payload) async {
    String? type = payload['type'];
    String id = payload['type_id'] ?? '';
    String urlLink = payload['link'] ?? '';

    switch (type) {
      case 'products':
        context.read<PushNotificationProvider>().getProduct(
          id,
          0,
          0,
          true,
          context,
        );
        break;
      case 'categories':
        if (Dashboard.dashboardScreenKey.currentState != null) {
          Dashboard.dashboardScreenKey.currentState!.changeTabPosition(1);
        }
        break;
      case 'wallet':
        Routes.navigateToMyWalletScreen(context);
        break;
      case 'cart':
        Routes.navigateToCartScreen(context, false);
        break;
      case 'order':
      case 'place_order':
        Routes.navigateToMyOrderScreen(context);
        break;
      case 'ticket_message':
        Routes.navigateToChatScreen(context, id, '');
        break;
      case 'ticket_status':
        Routes.navigateToCustomerSupportScreen(context);
        break;
      case 'notification_url':
        try {
          if (await canLaunchUrl(Uri.parse(urlLink))) {
            await launchUrl(
              Uri.parse(urlLink),
              mode: LaunchMode.externalApplication,
            );
          } else {
            throw 'Could not launch $urlLink';
          }
        } catch (e) {
          throw 'Something went wrong';
        }
        break;
      default:
        Routes.navigateToSplashScreen(context);
    }
  }
}
