import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/plant_model.dart';

class PlantRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<PlantModel>> getPlantsByGarden(int gardenId) async {
    final response = await _dio.get('${ApiConstants.gardens}/$gardenId/plants');
    final List<dynamic> data = response.data;
    return data.map((json) => PlantModel.fromJson(json)).toList();
  }

  Future<PlantModel> addPlant(int gardenId, PlantModel plant) async {
    final response = await _dio.post(
      '${ApiConstants.gardens}/$gardenId/plants',
      data: plant.toJson(),
    );
    return PlantModel.fromJson(response.data);
  }

  Future<PlantModel> updatePlant(int plantId, PlantModel plant) async {
    final response = await _dio.put('${ApiConstants.plants}/$plantId', data: plant.toJson());
    return PlantModel.fromJson(response.data);
  }

  Future<void> deletePlant(int plantId) async {
    await _dio.delete(
      '${ApiConstants.plants}/$plantId',
      options: Options(responseType: ResponseType.plain),
    );
  }

  Future<PlantModel> movePlant(int plantId, int targetGardenId) async {
    final response = await _dio.put('${ApiConstants.plants}/$plantId/move/$targetGardenId');
    return PlantModel.fromJson(response.data);
  }

  Future<String> uploadPlantImage(String filePath) async {
    return await ApiClient.uploadImage(filePath, 'plants');
  }
}
