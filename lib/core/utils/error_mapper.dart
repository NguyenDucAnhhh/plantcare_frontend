import 'package:dio/dio.dart';

class ErrorMapper {
  /// Hàm mới: Nhận vào một Object (Exception) bất kỳ và tự động dịch
  static String parseError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final errorCode = data['error']?.toString();
        final serverMessage = data['message']?.toString();
        return getErrorMessage(errorCode, serverMessage);
      }
    }
    
    // Nếu không phải lỗi HTTP (VD: mất mạng, lỗi code)
    return 'Lỗi hệ thống hoặc không có kết nối mạng!';
  }

  static String getErrorMessage(String? errorCode, String? fallbackMessage) {
    // 1. Nếu có Error Code từ Backend, ưu tiên dùng Từ điển này
    if (errorCode != null && errorCode.isNotEmpty) {
      switch (errorCode) {
        // --- Authentication & Account ---
        case 'AUTH_LOCKED':
          return 'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ Admin!';
        case 'AUTH_INVALID_CREDENTIALS':
          return 'Email hoặc mật khẩu không chính xác!';
        case 'AUTH_EMAIL_EXISTS':
          return 'Email đã được sử dụng!';
        case 'AUTH_INVALID_OTP':
          return 'Mã OTP không hợp lệ!';
        case 'AUTH_OTP_EXPIRED':
          return 'Mã OTP đã hết hạn!';
        case 'USER_NOT_FOUND':
          return 'Tài khoản không tồn tại!';
        case 'USER_WRONG_OLD_PASSWORD':
          return 'Mật khẩu cũ không chính xác!';
        
        // --- Content ---
        case 'POST_HIDDEN':
          return 'Bài đăng đã bị ẩn!';
        case 'INVALID_ACTION':
          return 'Hành động không hợp lệ!';
        case 'UPLOAD_AVATAR_FAILED':
          return 'Lỗi khi tải ảnh đại diện lên!';
          
        // --- Not Found Entities ---
        case 'COMMENT_NOT_FOUND':
          return 'Bình luận không tồn tại!';
        case 'POST_NOT_FOUND':
          return 'Bài đăng không tồn tại!';
        case 'GARDEN_NOT_FOUND':
          return 'Khu vườn không tồn tại!';
        case 'PLANT_NOT_FOUND':
          return 'Không tìm thấy cây!';
        case 'TIP_NOT_FOUND':
          return 'Không tìm thấy mẹo chăm sóc!';
        case 'REMINDER_NOT_FOUND':
          return 'Lịch nhắc nhở không tồn tại!';
        case 'DIAGNOSIS_NOT_FOUND':
          return 'Không tìm thấy kết quả chẩn đoán này!';
        case 'NOTIFICATION_NOT_FOUND':
          return 'Thông báo không tồn tại!';
        case 'REPORT_TICKET_NOT_FOUND':
          return 'Đơn báo cáo không tồn tại!';
      }
    }

    // 2. Nếu không tìm thấy mã lỗi, dùng câu tiếng Việt dự phòng từ Backend gửi về
    if (fallbackMessage != null && fallbackMessage.isNotEmpty) {
      return fallbackMessage.endsWith('!') ? fallbackMessage : '$fallbackMessage!';
    }

    // 3. Nếu không có gì cả, trả về lỗi chung chung
    return 'Lỗi hệ thống. Vui lòng thử lại sau!';
  }
}
