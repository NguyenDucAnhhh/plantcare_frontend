import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'care_tip_model.dart';

final careTipRepositoryProvider = Provider((ref) => CareTipRepository());

class CareTipRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<CareTipModel>> getAllCareTips() async {
    try {
      final response = await _dio.get(ApiConstants.careTips);
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
      final response = await _dio.get('${ApiConstants.careTips}/$id');
      return CareTipModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Lỗi khi tải chi tiết cẩm nang: $e');
    }
  }

  Future<String?> uploadImage(XFile file) async {
    try {
      return await ApiClient.uploadImage(file, 'tips');
    } catch (e) {
      throw Exception('Lỗi upload ảnh: $e');
    }
  }

  Future<CareTipModel> createCareTip(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.careTips, data: data);
      return CareTipModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Lỗi khi tạo cẩm nang: $e');
    }
  }

  Future<CareTipModel> updateCareTip(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('${ApiConstants.careTips}/$id', data: data);
      return CareTipModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật cẩm nang: $e');
    }
  }

  Future<void> deleteCareTip(int id) async {
    try {
      await _dio.delete('${ApiConstants.careTips}/$id');
    } catch (e) {
      throw Exception('Lỗi khi xóa cẩm nang: $e');
    }
  }
}
