import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

final diagnosisRepositoryProvider = Provider((ref) => DiagnosisRepository());

class DiagnosisRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<dynamic>> getDiagnosisHistory() async {
    final response = await _dio.get(ApiConstants.diagnosisHistory);
    return response.data as List<dynamic>;
  }

  Future<void> rateDiagnosis(int id, int rating) async {
    await _dio.post('${ApiConstants.diagnosis}/$id/rate', data: {'rating': rating});
  }

  Future<Map<String, dynamic>> analyzeDiagnosis(XFile image) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path, filename: image.name),
    });
    final response = await _dio.post('${ApiConstants.diagnosis}/analyze', data: formData);
    return response.data;
  }
}
