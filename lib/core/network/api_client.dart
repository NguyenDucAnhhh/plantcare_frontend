import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

/// Nha may san xuat Dio - Cau hinh HTTP Client dung cho toan app
/// Moi request gui di deu qua day: tu dong gan Token, xu ly loi chung
class ApiClient {
  ApiClient._();

  static Dio? _dio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // GAn INTERCEPTOR: Tu dong chen Token vao moi Request
    dio.interceptors.add(_AuthInterceptor());

    // LOG request/response khi debug (co the tat khi release)
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    return dio;
  }
}

/// Bo chan cuong truoc (Interceptor) - Nhan vien tu dong cap the vao moi don hang
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Lay Token tu ket sat bao mat
    final token = await SecureStorage.getToken();

    if (token != null) {
      // Chen Token vao Header: "Authorization: Bearer eyJ..."
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options); // Cho request di tiep
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Neu Server tra ve 401 (Token het han), xoa Token cu va chuyen ve man Dang nhap
    if (err.response?.statusCode == 401) {
      SecureStorage.clear();
      // Ghi chu: Viec chuyen man hinh se xu ly o lop Router
    }
    handler.next(err);
  }
}
