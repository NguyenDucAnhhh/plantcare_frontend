import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
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
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
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

  // Generic Upload Methods
  static Future<String> uploadImage(dynamic file, String folder) async {
    MultipartFile multipartFile;
    if (file is String) {
      multipartFile = await MultipartFile.fromFile(file);
    } else if (file is XFile) {
      final bytes = await file.readAsBytes();
      multipartFile = MultipartFile.fromBytes(bytes, filename: file.name);
    } else { // File from dart:io
      multipartFile = await MultipartFile.fromFile(file.path);
    }
    
    FormData formData = FormData.fromMap({
      'file': multipartFile,
    });
    
    final response = await instance.post(
      '/api/files/upload',
      queryParameters: {'folder': folder},
      data: formData,
      options: Options(responseType: ResponseType.plain),
    );
    return response.data as String;
  }

  static Future<List<String>> uploadMultipleImages(List<dynamic> files, String folder) async {
    List<MultipartFile> multipartFiles = [];
    for (var f in files) {
      if (f is String) {
        multipartFiles.add(await MultipartFile.fromFile(f));
      } else if (f is XFile) {
        final bytes = await f.readAsBytes();
        multipartFiles.add(MultipartFile.fromBytes(bytes, filename: f.name));
      } else {
        multipartFiles.add(await MultipartFile.fromFile(f.path));
      }
    }
    
    FormData formData = FormData.fromMap({
      'files': multipartFiles,
    });
    
    final response = await instance.post(
      '/api/files/upload-multiple',
      queryParameters: {'folder': folder},
      data: formData,
    );
    if (response.data != null) {
      return List<String>.from(response.data);
    }
    return [];
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
