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
  final List<HourlyForecast> hourlyForecast;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.weatherType,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    required this.description,
    required this.forecast,
    required this.hourlyForecast,
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
      hourlyForecast: [],
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
  final double minTemperature;
  final double maxTemperature;
  final WeatherType weatherType;
  final String description;
  final DateTime date;

  DailyForecast({
    required this.day,
    required this.minTemperature,
    required this.maxTemperature,
    required this.weatherType,
    required this.description,
    required this.date,
  });
}

class HourlyForecast {
  final String time;
  final double temperature;
  final WeatherType weatherType;
  final String description;
  final DateTime dateTime;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherType,
    required this.description,
    required this.dateTime,
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
        
        // Group forecasts by day
        Map<String, List<dynamic>> dailyForecasts = {};
        
        for (final forecast in forecastList) {
          final date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
          final dateKey = '${date.year}-${date.month}-${date.day}';
          
          if (!dailyForecasts.containsKey(dateKey)) {
            dailyForecasts[dateKey] = [];
          }
          dailyForecasts[dateKey]!.add(forecast);
        }
        
        List<DailyForecast> forecasts = [];
        int dayCount = 0;
        
        // Process each day to find min/max temperatures
        for (final dateKey in dailyForecasts.keys) {
          if (dayCount >= 7) break; // Limit to 7 days
          
          final dayForecasts = dailyForecasts[dateKey]!;
          double minTemp = double.infinity;
          double maxTemp = double.negativeInfinity;
          WeatherType dominantWeather = WeatherType.sunny;
          String dominantDescription = '';
          DateTime date = DateTime.now();
          
          // Find min/max temperatures and dominant weather for the day
          for (final forecast in dayForecasts) {
            final main = forecast['main'];
            final weather = forecast['weather'][0];
            final tempMin = (main['temp_min'] as num).toDouble();
            final tempMax = (main['temp_max'] as num).toDouble();
            
            // Update min/max temperatures
            if (tempMin < minTemp) minTemp = tempMin;
            if (tempMax > maxTemp) maxTemp = tempMax;
            
            // Use the weather from midday forecast for better representation
            final forecastDate = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
            if (forecastDate.hour >= 10 && forecastDate.hour <= 14) {
              dominantWeather = _getWeatherTypeFromDescription(weather['main']);
              dominantDescription = weather['description'];
              date = forecastDate;
            }
          }
          
          // If no midday forecast found, use the first one
          if (dominantDescription.isEmpty && dayForecasts.isNotEmpty) {
            final firstForecast = dayForecasts.first;
            final weather = firstForecast['weather'][0];
            dominantWeather = _getWeatherTypeFromDescription(weather['main']);
            dominantDescription = weather['description'];
            date = DateTime.fromMillisecondsSinceEpoch(firstForecast['dt'] * 1000);
          }
          
          forecasts.add(DailyForecast(
            day: _getDayName(date.weekday),
            minTemperature: minTemp,
            maxTemperature: maxTemp,
            weatherType: dominantWeather,
            description: dominantDescription,
            date: date,
          ));
          
          dayCount++;
        }
        
        print('Successfully fetched ${forecasts.length} days forecast with min/max temps');
        return forecasts;
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      print('Forecast API Error: $e');
      throw Exception('Error fetching forecast: $e');
    }
  }

  static Future<List<HourlyForecast>> fetchHourlyForecast(String cityName) async {
    try {
      print('Fetching hourly forecast for: $cityName');
      
      final response = await http.get(
        Uri.parse('$baseUrl/forecast?q=$cityName&appid=$apiKey&units=metric')
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> forecastList = jsonData['list'];
        
        List<HourlyForecast> hourlyForecasts = [];
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        // Get today's hourly forecasts (next 24 hours)
        for (final forecast in forecastList) {
          final dateTime = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
          final forecastDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
          
          // Only include forecasts for today
          if (forecastDay == today || 
              (forecastDay == today.add(const Duration(days: 1)) && dateTime.hour < 24)) {
            
            final main = forecast['main'];
            final weather = forecast['weather'][0];
            
            hourlyForecasts.add(HourlyForecast(
              time: _formatTime(dateTime),
              temperature: (main['temp'] as num).toDouble(),
              weatherType: _getWeatherTypeFromDescription(weather['main']),
              description: weather['description'],
              dateTime: dateTime,
            ));
          }
          
          // Limit to 24 forecasts (every 3 hours for 5 days = 40 total, but we only want today)
          if (hourlyForecasts.length >= 24) break;
        }
        
        print('Successfully fetched ${hourlyForecasts.length} hourly forecasts');
        return hourlyForecasts;
      } else {
        throw Exception('Failed to load hourly forecast data: ${response.statusCode}');
      }
    } catch (e) {
      print('Hourly Forecast API Error: $e');
      throw Exception('Error fetching hourly forecast: $e');
    }
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour == 0) return '12AM';
    if (hour == 12) return '12PM';
    if (hour < 12) return '${hour}AM';
    return '${hour - 12}PM';
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