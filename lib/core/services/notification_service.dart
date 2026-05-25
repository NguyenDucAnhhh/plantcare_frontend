import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
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
      debugPrint("Lỗi khởi tạo Local Notification: $e");
    }

    try {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint("Lỗi setForegroundNotificationPresentationOptions: $e");
    }

    final currentToken = await getFcmToken();
    debugPrint("======== MÃ FCM CỦA MÁY NÀY ========");
    debugPrint(currentToken);
    debugPrint("====================================");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Nhận được thông báo Foreground');
      
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
              ),
            ),
          );
        } catch (e) {
          debugPrint("Lỗi show notification: $e");
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Mở app từ thông báo: $message.notification?.title');
    });
  }

  Future<String?> getFcmToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Lỗi lấy FCM Token: $e');
      return null;
    }
  }
}