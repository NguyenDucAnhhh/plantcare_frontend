import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../data/weather_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

/// Provider lay thoi tiet
final weatherProvider = FutureProvider<WeatherModel>((ref) async {
  try {
    double lat = 21.03;
    double lon = 105.85;

    // Kiem tra quyen truy cap vi tri
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Ignore
    } else {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Ignore
      } else if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.low));
        lat = position.latitude;
        lon = position.longitude;
      } else {
        // Ignore
      }
    }

    
    final response = await ApiClient.instance.get(
      ApiConstants.weather,
      queryParameters: {'lat': lat, 'lon': lon},
    );
    
    return WeatherModel.fromJson(response.data as Map<String, dynamic>);
  } catch (e) {
    
    // Neu chua co API Key hoac loi mang -> dung du lieu gia lap tu Figma
    return WeatherModel.mock();
  }
});