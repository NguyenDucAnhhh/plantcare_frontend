import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/plant_model.dart';

class PlantRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<PlantModel>> getPlantsByGarden(int gardenId) async {
    final response = await _dio.get('/api/gardens/$gardenId/plants');
    final List<dynamic> data = response.data;
    return data.map((json) => PlantModel.fromJson(json)).toList();
  }

  Future<PlantModel> addPlant(int gardenId, PlantModel plant) async {
    final response = await _dio.post(
      '/api/gardens/$gardenId/plants',
      data: plant.toJson(),
    );
    return PlantModel.fromJson(response.data);
  }

  Future<PlantModel> updatePlant(int plantId, PlantModel plant) async {
    final response = await _dio.put('/api/plants/$plantId', data: plant.toJson());
    return PlantModel.fromJson(response.data);
  }

  Future<void> deletePlant(int plantId) async {
    await _dio.delete(
      '/api/plants/$plantId',
      options: Options(responseType: ResponseType.plain),
    );
  }

  Future<PlantModel> movePlant(int plantId, int targetGardenId) async {
    final response = await _dio.put('/api/plants/$plantId/move/$targetGardenId');
    return PlantModel.fromJson(response.data);
  }

  Future<String> uploadPlantImage(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      '/api/plants/image/upload',
      data: formData,
      options: Options(responseType: ResponseType.plain),
    );
    return response.data as String;
  }
}
