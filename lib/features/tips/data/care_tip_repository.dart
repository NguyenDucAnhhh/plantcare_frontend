import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import 'care_tip_model.dart';

final careTipRepositoryProvider = Provider((ref) => CareTipRepository());

class CareTipRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<CareTipModel>> getAllCareTips() async {
    try {
      final response = await _dio.get('/api/care-tips');
      if (response.data is List) {
        return (response.data as List)
            .map((e) => CareTipModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách cẩm nang: $e');
    }
  }

  Future<CareTipModel> getCareTipById(int id) async {
    try {
      final response = await _dio.get('/api/care-tips/$id');
      return CareTipModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Lỗi khi tải chi tiết cẩm nang: $e');
    }
  }

  Future<String?> uploadImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final multipartFile = MultipartFile.fromBytes(bytes, filename: file.name);
      
      FormData formData = FormData.fromMap({
        'files': [multipartFile],
      });

      final response = await _dio.post(
        '/api/posts/images/upload',
        data: formData,
      );

      if (response.data != null && (response.data as List).isNotEmpty) {
        return (response.data as List)[0].toString();
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi upload ảnh: $e');
    }
  }

  Future<CareTipModel> createCareTip(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/care-tips', data: data);
      return CareTipModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Lỗi khi tạo cẩm nang: $e');
    }
  }

  Future<CareTipModel> updateCareTip(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/api/care-tips/$id', data: data);
      return CareTipModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật cẩm nang: $e');
    }
  }

  Future<void> deleteCareTip(int id) async {
    try {
      await _dio.delete('/api/care-tips/$id');
    } catch (e) {
      throw Exception('Lỗi khi xóa cẩm nang: $e');
    }
  }
}
