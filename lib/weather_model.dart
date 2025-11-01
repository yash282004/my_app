import 'dart:convert';
import 'package:http/http.dart' as http;

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
  final String description;
  final List<DailyForecast> forecast;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.weatherType,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    required this.description,
    required this.forecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = json['main'];
    final weather = json['weather'][0];
    final wind = json['wind'];
    
    return WeatherData(
      cityName: json['name'],
      temperature: (main['temp'] as num).toDouble(),
      weatherType: _getWeatherTypeFromDescription(weather['main']),
      humidity: main['humidity'],
      windSpeed: (wind['speed'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      description: weather['description'],
      forecast: [],
    );
  }

  static WeatherType _getWeatherTypeFromDescription(String description) {
    final desc = description.toLowerCase();
    
    if (desc.contains('clear')) return WeatherType.sunny;
    if (desc.contains('rain') || desc.contains('drizzle') || desc.contains('shower')) return WeatherType.rainy;
    if (desc.contains('snow')) return WeatherType.snowy;
    if (desc.contains('cloud')) return WeatherType.cloudy;
    if (desc.contains('wind') || desc.contains('breeze')) return WeatherType.windy;
    if (desc.contains('mist') || desc.contains('fog') || desc.contains('haze')) return WeatherType.cloudy;
    
    return WeatherType.sunny;
  }
}

class DailyForecast {
  final String day;
  final double temperature;
  final WeatherType weatherType;
  final String description;
  final DateTime date;

  DailyForecast({
    required this.day,
    required this.temperature,
    required this.weatherType,
    required this.description,
    required this.date,
  });
}

class WeatherService {
  static const String apiKey = 'fc8147a011453ebda1e57e8b9d86bd6b';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  static Future<WeatherData> fetchWeatherData(String cityName) async {
    try {
      print('Fetching weather for: $cityName');
      
      final List<String> cityFormats = [
        cityName,
        '$cityName,US',
        '$cityName,IN',
        '$cityName,GB',
        '$cityName,JP',
      ];

      for (final format in cityFormats) {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/weather?q=$format&appid=$apiKey&units=metric')
          );
          
          print('API Response for $format: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            final jsonData = json.decode(response.body);
            print('Successfully fetched data for: ${jsonData['name']}');
            return WeatherData.fromJson(jsonData);
          } else if (response.statusCode == 404) {
            print('City not found: $format');
            continue;
          } else if (response.statusCode == 401) {
            throw Exception('Invalid API key. Please check your OpenWeatherMap API key.');
          } else {
            print('API error ${response.statusCode} for: $format');
            continue;
          }
        } catch (e) {
          print('Error for format $format: $e');
          continue;
        }
      }
      
      throw Exception('City "$cityName" not found. Try: "City,Country" format like "Paris,FR"');
      
    } catch (e) {
      print('Final error: $e');
      throw Exception('Error fetching weather: $e');
    }
  }
  
  static Future<List<DailyForecast>> fetchForecast(String cityName) async {
    try {
      print('Fetching forecast for: $cityName');
      
      final response = await http.get(
        Uri.parse('$baseUrl/forecast?q=$cityName&appid=$apiKey&units=metric')
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> forecastList = jsonData['list'];
        
        List<DailyForecast> forecasts = [];
        
        // Get one forecast per day (every 24 hours/8 intervals)
        for (int i = 0; i < forecastList.length && forecasts.length < 7; i += 8) {
          final forecast = forecastList[i];
          final main = forecast['main'];
          final weather = forecast['weather'][0];
          final date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
          
          forecasts.add(DailyForecast(
            day: _getDayName(date.weekday),
            temperature: (main['temp'] as num).toDouble(),
            weatherType: _getWeatherTypeFromDescription(weather['main']),
            description: weather['description'],
            date: date,
          ));
        }
        
        print('Successfully fetched ${forecasts.length} days forecast');
        return forecasts;
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      print('Forecast API Error: $e');
      throw Exception('Error fetching forecast: $e');
    }
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return 'Day';
    }
  }

  static WeatherType _getWeatherTypeFromDescription(String description) {
    final desc = description.toLowerCase();
    
    if (desc.contains('clear')) return WeatherType.sunny;
    if (desc.contains('rain') || desc.contains('drizzle') || desc.contains('shower')) return WeatherType.rainy;
    if (desc.contains('snow')) return WeatherType.snowy;
    if (desc.contains('cloud')) return WeatherType.cloudy;
    if (desc.contains('wind') || desc.contains('breeze')) return WeatherType.windy;
    if (desc.contains('mist') || desc.contains('fog') || desc.contains('haze')) return WeatherType.cloudy;
    
    return WeatherType.sunny;
  }
}