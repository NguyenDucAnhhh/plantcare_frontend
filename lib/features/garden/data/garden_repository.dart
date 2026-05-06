import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/garden_model.dart';

class GardenRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<GardenModel>> getMyGardens() async {
    final response = await _dio.get('/api/gardens');
    final List<dynamic> data = response.data;
    return data.map((json) => GardenModel.fromJson(json)).toList();
  }

  Future<GardenModel> createGarden(GardenModel garden) async {
    final response = await _dio.post('/api/gardens', data: garden.toJson());
    return GardenModel.fromJson(response.data);
  }

  Future<GardenModel> updateGarden(int id, GardenModel garden) async {
    final response = await _dio.put('/api/gardens/$id', data: garden.toJson());
    return GardenModel.fromJson(response.data);
  }

  Future<void> deleteGarden(int id) async {
    await _dio.delete(
      '/api/gardens/$id',
      options: Options(responseType: ResponseType.plain), // Backend tra ve plain text, khong phai JSON
    );
  }

  Future<String> uploadGardenImage(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      '/api/gardens/image/upload',
      data: formData,
      options: Options(responseType: ResponseType.plain), // Backend tra ve plain text URL, khong phai JSON
    );
    return response.data as String;
  }
}
