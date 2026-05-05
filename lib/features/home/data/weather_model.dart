/// Model du lieu thoi tiet tu OpenWeatherMap (qua Spring Boot /api/weather)
class WeatherModel {
  final double temperature;
  final String description;
  final String city;
  final int humidity;
  final int cloudPercent;
  final String icon; // Vi du: "01d", "02d"

  const WeatherModel({
    required this.temperature,
    required this.description,
    required this.city,
    required this.humidity,
    required this.cloudPercent,
    required this.icon,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['main']?['temp'] ?? 0).toDouble(),
      description: json['weather']?[0]?['description'] ?? 'Không rõ',
      city: json['name'] ?? 'Chưa xác định',
      humidity: json['main']?['humidity'] ?? 0,
      cloudPercent: json['clouds']?['all'] ?? 0,
      icon: json['weather']?[0]?['icon'] ?? '01d',
    );
  }

  // Du lieu gia lap khi chua co API Key
  factory WeatherModel.mock() {
    return const WeatherModel(
      temperature: 28,
      description: 'Trời nắng',
      city: 'Hà Nội',
      humidity: 65,
      cloudPercent: 20,
      icon: '01d',
    );
  }

  String get temperatureDisplay => '${temperature.round()}°C';
  String get humidityDisplay => 'Độ ẩm: $humidity%';
  String get cloudDisplay => '☁ $cloudPercent%';
  String get locationDisplay => '$city - $description';
}
