import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  ApiConstants._();

  // Tu dong chon URL dung theo nen tang
  // kIsWeb          -> Chrome     -> localhost:8080
  // Android Emulator -> 10.0.2.2:8080 (localhost cua may tinh)
  // Dien thoai that -> PHONE_IP:8080 (IP Wifi cua may tinh)
  //
  // De test tren dien thoai that, chay:
  //   flutter run --dart-define=PHONE_IP=192.168.x.x
  // Sau khi chay "ipconfig" va lay IPv4 Address
  static const String _phoneIp = String.fromEnvironment('PHONE_IP', defaultValue: '10.0.2.2');

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    return 'http://$_phoneIp:8080';
  }

  // === AUTH ===
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';

  // === USER ===
  static const String myProfile = '/api/users/me';
  static const String userProfile = '/api/users'; // + /{id}
  static const String updateAvatar = '/api/users/me/avatar';
  static const String followUser = '/api/users'; // + /{id}/follow
  static const String myFollowings = '/api/users/me/following';

  // === GARDEN ===
  static const String gardens = '/api/gardens';

  // === PLANT ===
  // Them cay: /api/gardens/{gardenId}/plants
  // Lay cay: /api/gardens/{gardenId}/plants
  // Sua/Xoa cay: /api/plants/{plantId}
  static const String plantsInGarden = '/api/gardens'; // + /{id}/plants
  static const String plants = '/api/plants';           // + /{id}

  // === REMINDER ===
  static const String remindersOfPlant = '/api/plants'; // + /{id}/reminders
  static const String reminders = '/api/reminders';     // + /{id}

  // === POST ===
  static const String posts = '/api/posts';

  // === COMMENT ===
  // /api/posts/{postId}/comments
  static const String commentsOfPost = '/api/posts'; // + /{id}/comments

  // === LIKE ===
  // /api/posts/{postId}/like
  static const String likePost = '/api/posts'; // + /{id}/like

  // === NOTIFICATION ===
  static const String notifications = '/api/notifications';

  // === DIAGNOSIS ===
  static const String diagnosis = '/api/diagnosis';
  static const String diagnosisHistory = '/api/diagnosis/history';

  // === WEATHER ===
  static const String weather = '/api/weather';

  // === CARE TIPS ===
  static const String careTips = '/api/care-tips';

  // === REPORT ===
  static const String reports = '/api/reports';
}
