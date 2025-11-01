// weather_model.dart

enum WeatherType {
  sunny,
  cloudy,
  rainy,
  snowy,
  windy,
}

class WeatherData {
  final String cityName;
  final double temperature;
  final WeatherType weatherType;
  final int humidity;
  final double windSpeed;
  final double feelsLike;
  final List<DailyForecast> forecast;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.weatherType,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    required this.forecast,
  });
}

class DailyForecast {
  final String day;
  final double temperature;
  final WeatherType weatherType;

  DailyForecast({
    required this.day,
    required this.temperature,
    required this.weatherType,
  });
}