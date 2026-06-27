import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/app_colors.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      await _localNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

      const AndroidInitializationSettings androidInitSettings =
          AndroidInitializationSettings('ic_notification');
      
      const InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings,
      );
      await _localNotificationsPlugin.initialize(settings: initSettings);

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'Thông báo quan trọng',
        description: 'Kênh này dùng cho các thông báo quan trọng.',
        importance: Importance.max,
      );

      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (e) {
      // Ignore
    }

    try {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      // Ignore
    }

    await getFcmToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      
      String? title = message.notification?.title ?? message.data['title'];
      String? body = message.notification?.body ?? message.data['body'];

      if (title != null && body != null) {
        try {
          _localNotificationsPlugin.show(
            id: message.hashCode.abs(),
            title: title,
            body: body,
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'Thông báo quan trọng',
                channelDescription: 'Kênh này dùng cho các thông báo quan trọng.',
                importance: Importance.max,
                priority: Priority.high,
                icon: 'ic_notification',
                color: AppColors.primaryLight,
              ),
            ),
          );
        } catch (e) {
          // Ignore
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle action if needed
    });
  }

  Future<String?> getFcmToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      return null;
    }
  }
}