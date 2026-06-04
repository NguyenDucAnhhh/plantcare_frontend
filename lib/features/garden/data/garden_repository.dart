import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/garden_model.dart';

class GardenRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<GardenModel>> getMyGardens() async {
    final response = await _dio.get(ApiConstants.gardens);
    final List<dynamic> data = response.data;
    return data.map((json) => GardenModel.fromJson(json)).toList();
  }

  Future<GardenModel> createGarden(GardenModel garden) async {
    final response = await _dio.post(ApiConstants.gardens, data: garden.toJson());
    return GardenModel.fromJson(response.data);
  }

  Future<GardenModel> updateGarden(int id, GardenModel garden) async {
    final response = await _dio.put('${ApiConstants.gardens}/$id', data: garden.toJson());
    return GardenModel.fromJson(response.data);
  }

  Future<void> deleteGarden(int id) async {
    await _dio.delete(
      '${ApiConstants.gardens}/$id',
      options: Options(responseType: ResponseType.plain), // Backend tra ve plain text, khong phai JSON
    );
  }

  Future<String> uploadGardenImage(dynamic image) async {
    return await ApiClient.uploadImage(image, 'gardens');
  }
}
