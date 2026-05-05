import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/weather_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

/// Provider lay thoi tiet - Tra ve mock data neu chua co API Key
final weatherProvider = FutureProvider<WeatherModel>((ref) async {
  try {
    // Hanoi: lat=21.03, lon=105.85
    final response = await ApiClient.instance.get(
      ApiConstants.weather,
      queryParameters: {'lat': 21.03, 'lon': 105.85},
    );
    return WeatherModel.fromJson(response.data as Map<String, dynamic>);
  } catch (_) {
    // Neu chua co API Key hoac loi mang -> dung du lieu gia lap tu Figma
    return WeatherModel.mock();
  }
});
