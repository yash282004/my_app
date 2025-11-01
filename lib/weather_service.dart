// weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_model.dart';

class WeatherService {
  static const String apiKey = 'af6d240bab15c0e9dd56d60547c4be55'; // Replace with your actual API key
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<WeatherData> fetchWeatherData(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/weather?q=$cityName&appid=$apiKey&units=metric')
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return WeatherData.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('City not found');
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch weather data: $e');
    }
  }

  // Helper method to get weather icon based on condition
  static String getWeatherIcon(WeatherType weatherType) {
    switch (weatherType) {
      case WeatherType.sunny:
        return '☀️';
      case WeatherType.cloudy:
        return '☁️';
      case WeatherType.rainy:
        return '🌧️';
      case WeatherType.snowy:
        return '❄️';
      case WeatherType.windy:
        return '💨';
    }
  }

  // Get 5-day forecast (premium feature, but we'll simulate it)
  static Future<List<DailyForecast>> fetchForecast(String cityName) async {
    // Since 5-day forecast requires premium, we'll return mock data
    // You can upgrade to One Call API 3.0 for free forecast data
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    
    return List.generate(5, (index) {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return DailyForecast(
        day: days[index],
        temperature: 20.0 + (index * 2),
        weatherType: WeatherType.values[index % WeatherType.values.length],
        description: 'Partly cloudy',
      );
    });
  }
}