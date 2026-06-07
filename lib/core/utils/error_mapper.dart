import 'package:dio/dio.dart';

class ErrorMapper {
  /// Hàm mới: Nhận vào một Object (Exception) bất kỳ và tự động dịch
  static String parseError(Object e) {
    if (e is DioException) {
      if (e.response?.statusCode == 413) {
        return 'Tệp quá dung lượng (tối đa 10MB). Vui lòng chọn ảnh khác!';
      }
      final data = e.response?.data;
      if (data is Map) {
        final serverMessage = data['message']?.toString();
        return getErrorMessage(serverMessage);
      }
    }
    
    // Nếu không phải lỗi HTTP (VD: mất mạng, lỗi code)
    return 'Lỗi hệ thống hoặc không có kết nối mạng!';
  }

  static String getErrorMessage(String? fallbackMessage) {
    // Luôn ưu tiên dùng thông báo tiếng Việt trực tiếp từ Backend gửi về
    if (fallbackMessage != null && fallbackMessage.isNotEmpty) {
      return fallbackMessage.endsWith('!') ? fallbackMessage : '$fallbackMessage!';
    }

    // Nếu Backend không gửi thông báo nào, trả về lỗi chung chung
    return 'Lỗi hệ thống. Vui lòng thử lại sau!';
  }
}
