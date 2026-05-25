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
      print('=== WEATHER ERROR: GPS chua duoc bat tren dien thoai ===');
    } else {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('=== WEATHER ERROR: Quyen vi tri bi tu choi vinh vien ===');
      } else if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.low));
        lat = position.latitude;
        lon = position.longitude;
        print('=== WEATHER SUCCESS: Da lay duoc toa do Lat: $lat, Lon: $lon ===');
      } else {
        print('=== WEATHER ERROR: Quyen vi tri bi tu choi ===');
      }
    }

    print('=== WEATHER INFO: Dang goi API \ voi IP \ ===');
    final response = await ApiClient.instance.get(
      ApiConstants.weather,
      queryParameters: {'lat': lat, 'lon': lon},
    );
    print('=== WEATHER SUCCESS: Nhan ket qua API thanh cong ===');
    return WeatherModel.fromJson(response.data as Map<String, dynamic>);
  } catch (e) {
    print('=== WEATHER FATAL ERROR: \ ===');
    // Neu chua co API Key hoac loi mang -> dung du lieu gia lap tu Figma
    return WeatherModel.mock();
  }
});