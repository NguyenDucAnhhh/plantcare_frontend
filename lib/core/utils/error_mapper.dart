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
    return 'Lỗi hệ thống hoặc không có kết nối mạng.';
  }

  static String getErrorMessage(String? errorCode, String? fallbackMessage) {
    // 1. Nếu có Error Code từ Backend, ưu tiên dùng Từ điển này
    if (errorCode != null && errorCode.isNotEmpty) {
      switch (errorCode) {
        // --- Authentication & Account ---
        case 'AUTH_LOCKED':
          return 'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ Admin!';
        case 'AUTH_INVALID_CREDENTIALS':
          return 'Email hoặc mật khẩu không chính xác.';
        case 'AUTH_EMAIL_EXISTS':
          return 'Email đã được sử dụng';
        case 'AUTH_INVALID_OTP':
          return 'Mã OTP không hợp lệ!';
        case 'AUTH_OTP_EXPIRED':
          return 'Mã OTP đã hết hạn!';
        case 'USER_NOT_FOUND':
          return 'Tài khoản không tồn tại!';
        case 'USER_WRONG_OLD_PASSWORD':
          return 'Mật khẩu cũ không chính xác!';
        case 'USER_CANNOT_FOLLOW_SELF':
          return 'Bạn không thể tự theo dõi chính mình!';

        // --- Permissions & Access ---
        case 'FORBIDDEN_ADMIN_ONLY':
          return 'Chỉ Quản trị viên (ADMIN) mới có quyền thực hiện hành động này!';
        case 'FORBIDDEN_DELETE_COMMENT':
          return 'Bạn không có quyền xóa bình luận này!';
        case 'FORBIDDEN_RATE_DIAGNOSIS':
          return 'Bạn không có quyền đánh giá chẩn đoán này!';
        case 'FORBIDDEN_GARDEN_ACCESS':
          return 'Bạn không có quyền truy cập hoặc thao tác trên khu vườn này!';
        case 'FORBIDDEN_NOTIFICATION_ACCESS':
          return 'Bạn không có quyền thao tác thông báo này!';
        case 'FORBIDDEN_PLANT_ACCESS':
          return 'Bạn không có quyền truy cập hoặc thao tác với cây này!';
        case 'FORBIDDEN_EDIT_POST':
          return 'Bạn không có quyền sửa bài viết của người khác!';
        case 'FORBIDDEN_DELETE_POST':
          return 'Bạn không có quyền xóa bài viết của người khác!';
        case 'FORBIDDEN_EDIT_REMINDER':
          return 'Bạn không có quyền sửa báo thức này!';
        
        // --- Content ---
        case 'POST_HIDDEN':
          return 'Bài viết đã bị ẩn!';
        case 'INVALID_ACTION':
          return 'Hành động không hợp lệ!';
        case 'UPLOAD_AVATAR_FAILED':
          return 'Lỗi khi tải ảnh đại diện lên.';
          
        // Thêm các mã lỗi mới vào đây trong tương lai
      }
    }

    // 2. Nếu không tìm thấy mã lỗi, dùng câu tiếng Việt dự phòng từ Backend gửi về
    if (fallbackMessage != null && fallbackMessage.isNotEmpty) {
      return fallbackMessage;
    }

    // 3. Nếu không có gì cả, trả về lỗi chung chung
    return 'Lỗi hệ thống. Vui lòng thử lại sau.';
  }
}
