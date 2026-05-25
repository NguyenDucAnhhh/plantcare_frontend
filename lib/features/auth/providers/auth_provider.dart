import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../models/auth_response.dart';
import '../../../core/services/notification_service.dart';

// Trang thai cua man hinh Auth
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final AuthResponse? user;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    AuthResponse? user,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
    );
  }
}

// Provider chinh quan ly xac thuc
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  /// Xu ly Dang Nhap
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.login(email: email, password: password);
      
      // === FIREBASE PUSH NOTIFICATION ===
      // Lay Token cua thiet bi va bao cho Server biet
      try {
        final notificationService = NotificationService();
        final token = await notificationService.getFcmToken();
        if (token != null) {
          await _repository.updateFcmToken(token);
        }
      } catch (e) {
        print("Loi update FCM: $e");
      }

      state = state.copyWith(isLoading: false, user: user);
      return true; // Thanh cong
    } on DioException catch (e) {
      final message = _parseError(e);
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false; // That bai
    }
  }

  /// Xu ly Dang Ky
  Future<bool> register(String fullName, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } on DioException catch (e) {
      final message = _parseError(e);
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false;
    }
  }

  /// Xu ly Dang Xuat
  Future<void> logout() async {
    // 0. Xoá FCM Token trên server trước khi xoá local token
    try {
      await _repository.updateFcmToken("");
    } catch (e) {
      // Bỏ qua lỗi nếu mất mạng
    }
    
    // 1. Gọi xuống Repository để xóa két sắt (Token)
    await _repository.logout();
    
    // 2. Reset toàn bộ trạng thái AuthState về rỗng như lúc mới mở App
    state = const AuthState();
  }

  /// QUEN MAT KHAU
  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.forgotPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      final message = _parseError(e);
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.verifyOtp(email, otp);
      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      final message = _parseError(e);
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false;
    }
  }

  Future<bool> resetPassword(String email, String otp, String newPassword) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.resetPassword(email, otp, newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      final message = _parseError(e);
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false;
    }
  }

  /// Dich ma loi tu Spring Boot sang tieng Viet de hien thi cho User
  String _parseError(DioException e) {
    final statusCode = e.response?.statusCode;
    final serverMessage = e.response?.data?['message'];

    if (serverMessage != null) return serverMessage;

    return switch (statusCode) {
      400 => 'Thong tin khong hop le. Vui long kiem tra lai.',
      401 => 'Email hoac mat khau khong dung.',
      409 => 'Email nay da duoc su dung.',
      500 => 'Loi may chu. Vui long thu lai sau.',
      _ => 'Khong co ket noi mang (${e.message}).',
    };
  }
}

// Expose Provider ra ben ngoai de Screen dung
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthRepository());
});
