
class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    // Đã trỏ thẳng lên máy chủ thật!
    return 'https://plantcare-backend-g2bj.onrender.com';
  }

  // === AUTH ===
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String resetPassword = '/api/auth/reset-password';

  // === USER ===
  static const String myProfile = '/api/users/me';
  static const String userProfile = '/api/users'; // + /{id}
  static const String searchUsers = '/api/users/search';
  static const String updateAvatar = '/api/users/me/avatar/upload';
  static const String changePassword = '/api/users/me/change-password';
  static const String notificationSettings = '/api/users/me/notification-settings';
  static const String updateFcmToken = '/api/users/fcm-token';
  static const String followUser = '/api/users'; // + /{id}/follow
  static const String myFollowings = '/api/users/me/following';

  // === GARDEN ===
  static const String gardens = '/api/gardens';

  // === PLANT ===
  static const String plantsInGarden = '/api/gardens'; // + /{id}/plants
  static const String plants = '/api/plants';           // + /{id}

  // === REMINDER ===
  static const String remindersOfPlant = '/api/plants'; // + /{id}/reminders
  static const String reminders = '/api/reminders';     // + /{id}

  // === POST ===
  static const String posts = '/api/posts';
  static const String myPosts = '/api/posts/me';
  static const String userPosts = '/api/posts/user'; // + /{userId}
  static const String searchPosts = '/api/posts/search';

  // === COMMENT ===
  static const String commentsOfPost = '/api/posts'; // + /{id}/comments

  // === LIKE ===
  static const String likePost = '/api/posts'; // + /{id}/like

  // === NOTIFICATION ===
  static const String notifications = '/api/notifications';

  // === DIAGNOSIS ===
  static const String diagnosis = '/api/diagnosis';
  static const String diagnosisHistory = '/api/diagnosis/history';

  // === WEATHER ===
  static const String weather = '/api/weather/current';

  // === CARE TIPS ===
  static const String careTips = '/api/care-tips';

  // === REPORT ===
  static const String reports = '/api/reports';

  // === FILE UPLOAD ===
  static const String uploadFile = '/api/files/upload';
  static const String uploadMultipleFiles = '/api/files/upload-multiple';
}
