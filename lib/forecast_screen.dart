import 'package:flutter/material.dart';
import 'glassmorphic_container.dart';
import 'weather_model.dart';
import 'weather_animations.dart';

class ForecastScreen extends StatefulWidget {
  final String currentCity;

  const ForecastScreen({super.key, required this.currentCity});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  WeatherType _currentWeather = WeatherType.sunny;
  bool _isDarkTheme = false;
  WeatherData? _weatherData;
  bool _isLoading = false;
  String _errorMessage = '';
  List<DailyForecast> _forecastData = [];

  @override
  void initState() {
    super.initState();
    // Use the currentCity passed from home screen
    if (widget.currentCity.isNotEmpty) {
      _fetchWeatherForCity(widget.currentCity);
    }
  }

  @override
  void didUpdateWidget(ForecastScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentCity != widget.currentCity) {
      _fetchWeatherForCity(widget.currentCity);
    }
  }

  Future<void> _fetchWeatherForCity(String cityName) async {
    if (cityName.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final weatherData = await WeatherService.fetchWeatherData(cityName);
      final forecastData = await WeatherService.fetchForecast(cityName);
      
      setState(() {
        _weatherData = weatherData;
        _currentWeather = weatherData.weatherType;
        _forecastData = forecastData;
        _isLoading = false;
      });
      
    } catch (e) {
      print('API Error: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Color _getPrimaryColor() {
    return _getColorForWeatherType(_currentWeather, _isDarkTheme);
  }

  Color _getColorForWeatherType(WeatherType type, bool isDark) {
    switch (type) {
      case WeatherType.sunny:
        return isDark ? const Color(0xFFFFB74D) : Color(0xFFFF9800);
      case WeatherType.cloudy:
        return isDark ? const Color(0xFF90A4AE) : Color(0xFF607D8B);
      case WeatherType.rainy:
        return isDark ? const Color(0xFF64B5F6) : Color(0xFF2196F3);
      case WeatherType.snowy:
        return isDark ? const Color(0xFFE3F2FD) : Color(0xFFBBDEFB);
      case WeatherType.windy:
        return isDark ? const Color(0xFF81C784) : Color(0xFF4CAF50);
    }
  }

  List<Color> _getBackgroundGradient() {
    if (_isDarkTheme) {
      switch (_currentWeather) {
        case WeatherType.sunny:
          return [const Color(0xFF2C3E50), Color(0xFF34495E)];
        case WeatherType.cloudy:
          return [const Color(0xFF2C3E50), Color(0xFF4A6572)];
        case WeatherType.rainy:
          return [const Color(0xFF0D47A1), Color(0xFF1976D2)];
        case WeatherType.snowy:
          return [const Color(0xFF1A237E), Color(0xFF283593)];
        case WeatherType.windy:
          return [const Color(0xFF1B5E20), Color(0xFF2E7D32)];
      }
    } else {
      switch (_currentWeather) {
        case WeatherType.sunny:
          return [const Color(0xFF87CEEB), Color(0xFF1E90FF)];
        case WeatherType.cloudy:
          return [const Color(0xFFB0BEC5), Color(0xFF78909C)];
        case WeatherType.rainy:
          return [const Color(0xFF546E7A), Color(0xFF37474F)];
        case WeatherType.snowy:
          return [const Color(0xFFE3F2FD), Color(0xFFBBDEFB)];
        case WeatherType.windy:
          return [const Color(0xFF80CBC4), Color(0xFF26A69A)];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header with Search
                _buildHeader(),

                const SizedBox(height: 20),

                // Loading Indicator or Forecast List
                if (_isLoading) _buildLoadingIndicator()
                else if (_errorMessage.isNotEmpty) _buildErrorWidget()
                else _buildForecastList(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getBackgroundGradient(),
        ),
      ),
      child: WeatherAnimations(
        weatherType: _currentWeather,
        isDarkTheme: _isDarkTheme,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 60,
        borderRadius: 20,
        blur: 20,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: TextEditingController(text: widget.currentCity),
                  decoration: InputDecoration(
                    hintText: "Search city for forecast...",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _fetchWeatherForCity(value);
                    }
                  },
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                _isDarkTheme ? Icons.nightlight_round : Icons.wb_sunny,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isDarkTheme = !_isDarkTheme;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Expanded(
      child: Center(
        child: GlassmorphicContainer(
          width: 200,
          height: 200,
          borderRadius: 30,
          blur: 20,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.5),
              Colors.white.withOpacity(0.1),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_getPrimaryColor()),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading forecast for ${widget.currentCity}...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Expanded(
      child: Center(
        child: GlassmorphicContainer(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 200,
          borderRadius: 30,
          blur: 20,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.5),
              Colors.white.withOpacity(0.1),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[300],
                size: 50,
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPrimaryColor(),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _fetchWeatherForCity(widget.currentCity),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForecastList() {
    final forecastToShow = _forecastData.isNotEmpty ? _forecastData : _getFallbackForecast();
    
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Text(
              'Day Forecast for ${widget.currentCity}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: forecastToShow.length,
              itemBuilder: (context, index) {
                final forecast = forecastToShow[index];
                return _buildForecastItem(forecast, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastItem(DailyForecast forecast, int index) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 80,
      borderRadius: 20,
      blur: 15,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.1),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Day and Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  forecast.day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Icon(
                  _getWeatherIcon(forecast.weatherType),
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),

          // Weather Description
          Expanded(
            child: Text(
              forecast.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),

          // Temperature Range
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Max Temperature
                Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: Colors.red[200],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${forecast.maxTemperature.toStringAsFixed(0)}°",
                      style: TextStyle(
                        color: Colors.red[200],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Min Temperature
                Row(
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      color: Colors.blue[200],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${forecast.minTemperature.toStringAsFixed(0)}°",
                      style: TextStyle(
                        color: Colors.blue[200],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DailyForecast> _getFallbackForecast() {
    final baseTemp = _weatherData?.temperature ?? 20;
    return [
      DailyForecast(day: 'Monday', minTemperature: baseTemp - 2, maxTemperature: baseTemp + 3, weatherType: _currentWeather, description: 'Partly Cloudy', date: DateTime.now()),
      DailyForecast(day: 'Tuesday', minTemperature: baseTemp - 1, maxTemperature: baseTemp + 4, weatherType: _currentWeather, description: 'Sunny', date: DateTime.now()),
      DailyForecast(day: 'Wednesday', minTemperature: baseTemp - 2, maxTemperature: baseTemp + 2, weatherType: _currentWeather, description: 'Cloudy', date: DateTime.now()),
      DailyForecast(day: 'Thursday', minTemperature: baseTemp - 3, maxTemperature: baseTemp + 1, weatherType: _currentWeather, description: 'Rainy', date: DateTime.now()),
      DailyForecast(day: 'Friday', minTemperature: baseTemp - 1, maxTemperature: baseTemp + 3, weatherType: _currentWeather, description: 'Sunny', date: DateTime.now()),
      DailyForecast(day: 'Saturday', minTemperature: baseTemp, maxTemperature: baseTemp + 5, weatherType: _currentWeather, description: 'Clear', date: DateTime.now()),
      DailyForecast(day: 'Sunday', minTemperature: baseTemp - 2, maxTemperature: baseTemp + 2, weatherType: _currentWeather, description: 'Windy', date: DateTime.now()),
    ];
  }

  IconData _getWeatherIcon(WeatherType type) {
    switch (type) {
      case WeatherType.sunny:
        return Icons.wb_sunny;
      case WeatherType.cloudy:
        return Icons.cloud;
      case WeatherType.rainy:
        return Icons.beach_access;
      case WeatherType.snowy:
        return Icons.ac_unit;
      case WeatherType.windy:
        return Icons.air;
    }
  }
}