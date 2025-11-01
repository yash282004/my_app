// main_weather_screen.dart
import 'package:flutter/material.dart';
import 'glassmorphic_container.dart';
import 'weather_model.dart';
import 'weather_animations.dart';

class MainWeatherScreen extends StatefulWidget {
  const MainWeatherScreen({super.key});

  @override
  State<MainWeatherScreen> createState() => _MainWeatherScreenState();
}

class _MainWeatherScreenState extends State<MainWeatherScreen> {
  WeatherType _currentWeather = WeatherType.sunny;
  bool _isDarkTheme = false;
  String _cityName = "New York";

  final List<String> _weatherQuotes = [
    "Every day may not be sunny, but there's something good in every day.",
    "Clouds come floating into my life, no longer to carry rain but to add color to my sunset sky.",
    "Some people feel the rain. Others just get wet.",
    "A snowflake is one of nature's most fragile things, but look what they can do when they stick together!",
    "The wind shows us how close to the edge we are.",
  ];

  Color _getPrimaryColor() {
    switch (_currentWeather) {
      case WeatherType.sunny:
        return _isDarkTheme ? const Color(0xFFFFB74D) : Color(0xFFFF9800);
      case WeatherType.cloudy:
        return _isDarkTheme ? const Color(0xFF90A4AE) : Color(0xFF607D8B);
      case WeatherType.rainy:
        return _isDarkTheme ? const Color(0xFF64B5F6) : Color(0xFF2196F3);
      case WeatherType.snowy:
        return _isDarkTheme ? const Color(0xFFE3F2FD) : Color(0xFFBBDEFB);
      case WeatherType.windy:
        return _isDarkTheme ? const Color(0xFF81C784) : Color(0xFF4CAF50);
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
                // Header with Search and Theme Toggle
                _buildHeader(),

                const SizedBox(height: 20),

                // Main Weather Card
                _buildWeatherCard(),

                const Spacer(),

                // Motivational Quote
                _buildQuoteCard(),

                const SizedBox(height: 20),

                // Forecast Slider
                _buildForecastSlider(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentWeather = WeatherType
                .values[(_currentWeather.index + 1) % WeatherType.values.length];
          });
        },
        child: const Icon(Icons.refresh),
        backgroundColor: _getPrimaryColor(),
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
                  decoration: InputDecoration(
                    hintText: "Search city...",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _cityName = value;
                    });
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

  Widget _buildWeatherCard() {
    return GlassmorphicContainer(
      width: MediaQuery.of(context).size.width * 0.9,
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
          Text(
            _cityName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWeatherIcon(),
              const SizedBox(width: 20),
              Text(
                "22°C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWeatherDetail("Humidity", "65%", Icons.opacity),
              _buildWeatherDetail("Wind", "15 km/h", Icons.air),
              _buildWeatherDetail("Feels Like", "24°C", Icons.thermostat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon() {
    IconData icon;
    switch (_currentWeather) {
      case WeatherType.sunny:
        icon = Icons.wb_sunny;
        break;
      case WeatherType.cloudy:
        icon = Icons.cloud;
        break;
      case WeatherType.rainy:
        icon = Icons.beach_access;
        break;
      case WeatherType.snowy:
        icon = Icons.ac_unit;
        break;
      case WeatherType.windy:
        icon = Icons.air;
        break;
    }

    return Icon(
      icon,
      color: _getPrimaryColor(),
      size: 60,
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteCard() {
    return GlassmorphicContainer(
      width: MediaQuery.of(context).size.width * 0.85,
      height: 80,
      borderRadius: 20,
      blur: 15,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.15),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          _weatherQuotes[_currentWeather.index],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildForecastSlider() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 7,
        itemBuilder: (context, index) {
          return GlassmorphicContainer(
            width: 80,
            height: 100,
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
            margin: EdgeInsets.only(right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Day ${index + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Icon(Icons.wb_sunny, color: Colors.white, size: 24),
                const SizedBox(height: 5),
                Text(
                  "24°C",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}