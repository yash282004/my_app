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
  WeatherData? _weatherData;
  bool _isLoading = false;
  String _errorMessage = '';
  List<DailyForecast> _forecastData = [];

  final List<String> _weatherQuotes = [
    "Every day may not be sunny, but there's something good in every day.",
    "Clouds come floating into my life, no longer to carry rain but to add color to my sunset sky.",
    "Some people feel the rain. Others just get wet.",
    "A snowflake is one of nature's most fragile things, but look what they can do when they stick together!",
    "The wind shows us how close to the edge we are.",
  ];

  @override
  void initState() {
    super.initState();
    _fetchWeatherForCity(_cityName);
  }

  Future<void> _fetchWeatherForCity(String cityName) async {
    if (cityName.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _cityName = cityName;
    });

    try {
      // Fetch current weather and forecast simultaneously
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
      
      if (_isCommonCity(cityName)) {
        await _mockFetchWeather(cityName);
      } else {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  bool _isCommonCity(String cityName) {
    final commonCities = [
      'paris', 'london', 'new york', 'tokyo', 'sydney', 
      'berlin', 'mumbai', 'delhi', 'bangalore', 'chennai'
    ];
    return commonCities.contains(cityName.toLowerCase());
  }

  Future<void> _mockFetchWeather(String cityName) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final mockData = {
      'london': WeatherData(
        cityName: 'London',
        temperature: 15.0,
        weatherType: WeatherType.cloudy,
        humidity: 78,
        windSpeed: 12.0,
        feelsLike: 14.0,
        description: 'Cloudy',
        forecast: [],
      ),
      'paris': WeatherData(
        cityName: 'Paris',
        temperature: 22.0,
        weatherType: WeatherType.sunny,
        humidity: 65,
        windSpeed: 8.0,
        feelsLike: 23.0,
        description: 'Sunny',
        forecast: [],
      ),
      'tokyo': WeatherData(
        cityName: 'Tokyo',
        temperature: 18.0,
        weatherType: WeatherType.rainy,
        humidity: 85,
        windSpeed: 6.0,
        feelsLike: 17.0,
        description: 'Light rain',
        forecast: [],
      ),
      'new york': WeatherData(
        cityName: 'New York',
        temperature: 20.0,
        weatherType: WeatherType.windy,
        humidity: 70,
        windSpeed: 18.0,
        feelsLike: 19.0,
        description: 'Windy',
        forecast: [],
      ),
      'sydney': WeatherData(
        cityName: 'Sydney',
        temperature: 25.0,
        weatherType: WeatherType.sunny,
        humidity: 60,
        windSpeed: 10.0,
        feelsLike: 26.0,
        description: 'Clear sky',
        forecast: [],
      ),
      'berlin': WeatherData(
        cityName: 'Berlin',
        temperature: 16.0,
        weatherType: WeatherType.cloudy,
        humidity: 75,
        windSpeed: 9.0,
        feelsLike: 15.0,
        description: 'Partly cloudy',
        forecast: [],
      ),
      'mumbai': WeatherData(
        cityName: 'Mumbai',
        temperature: 32.0,
        weatherType: WeatherType.sunny,
        humidity: 65,
        windSpeed: 12.0,
        feelsLike: 35.0,
        description: 'Sunny',
        forecast: [],
      ),
      'delhi': WeatherData(
        cityName: 'Delhi',
        temperature: 28.0,
        weatherType: WeatherType.sunny,
        humidity: 45,
        windSpeed: 8.0,
        feelsLike: 29.0,
        description: 'Clear sky',
        forecast: [],
      ),
      'bangalore': WeatherData(
        cityName: 'Bangalore',
        temperature: 26.0,
        weatherType: WeatherType.cloudy,
        humidity: 70,
        windSpeed: 6.0,
        feelsLike: 27.0,
        description: 'Cloudy',
        forecast: [],
      ),
      'chennai': WeatherData(
        cityName: 'Chennai',
        temperature: 30.0,
        weatherType: WeatherType.sunny,
        humidity: 75,
        windSpeed: 10.0,
        feelsLike: 33.0,
        description: 'Sunny',
        forecast: [],
      ),
    };

    final mockForecast = [
      DailyForecast(day: 'Mon', temperature: 16.0, weatherType: WeatherType.cloudy, description: 'Cloudy', date: DateTime.now().add(const Duration(days: 1))),
      DailyForecast(day: 'Tue', temperature: 17.0, weatherType: WeatherType.rainy, description: 'Light rain', date: DateTime.now().add(const Duration(days: 2))),
      DailyForecast(day: 'Wed', temperature: 18.0, weatherType: WeatherType.cloudy, description: 'Partly cloudy', date: DateTime.now().add(const Duration(days: 3))),
      DailyForecast(day: 'Thu', temperature: 19.0, weatherType: WeatherType.sunny, description: 'Sunny', date: DateTime.now().add(const Duration(days: 4))),
      DailyForecast(day: 'Fri', temperature: 20.0, weatherType: WeatherType.sunny, description: 'Clear', date: DateTime.now().add(const Duration(days: 5))),
      DailyForecast(day: 'Sat', temperature: 21.0, weatherType: WeatherType.cloudy, description: 'Cloudy', date: DateTime.now().add(const Duration(days: 6))),
      DailyForecast(day: 'Sun', temperature: 22.0, weatherType: WeatherType.rainy, description: 'Rain', date: DateTime.now().add(const Duration(days: 7))),
    ];

    final cityKey = cityName.toLowerCase();
    setState(() {
      _weatherData = mockData[cityKey] ?? mockData['new york']!;
      _currentWeather = _weatherData!.weatherType;
      _forecastData = mockForecast;
      _isLoading = false;
    });
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
          _buildAnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                if (_isLoading) _buildLoadingIndicator()
                else if (_errorMessage.isNotEmpty) _buildErrorWidget()
                else _buildWeatherCard(),
                const Spacer(),
                if (!_isLoading && _errorMessage.isEmpty) _buildQuoteCard(),
                const SizedBox(height: 20),
                if (!_isLoading && _errorMessage.isEmpty) _buildForecastSlider(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isLoading ? null : FloatingActionButton(
        onPressed: () {
          if (_weatherData != null) {
            _fetchWeatherForCity(_weatherData!.cityName);
          }
        },
        child: const Icon(Icons.refresh),
        backgroundColor: _getPrimaryColor(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
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
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_getPrimaryColor()),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading weather for $_cityName...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return GlassmorphicContainer(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 240,
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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Try: "City,Country" format\nExample: "Delhi,IN" or "Berlin,DE"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _getPrimaryColor(),
              foregroundColor: Colors.white,
            ),
            onPressed: () => _fetchWeatherForCity(_cityName),
            child: const Text('Try Again'),
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
                  decoration: InputDecoration(
                    hintText: "Search city (e.g., 'Paris' or 'Delhi,IN')",
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

  Widget _buildWeatherCard() {
    final data = _weatherData!;
    
    return GlassmorphicContainer(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 240,
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
            data.cityName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            data.description.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWeatherIcon(),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${data.temperature.toStringAsFixed(1)}°C",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    "Feels like ${data.feelsLike.toStringAsFixed(1)}°C",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWeatherDetail("Humidity", "${data.humidity}%", Icons.opacity),
              _buildWeatherDetail("Wind", "${data.windSpeed.toStringAsFixed(1)} km/h", Icons.air),
              _buildWeatherDetail("Feels Like", "${data.feelsLike.toStringAsFixed(1)}°C", Icons.thermostat),
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
    final forecastToShow = _forecastData.isNotEmpty ? _forecastData : _getFallbackForecast();
    
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: forecastToShow.length,
        itemBuilder: (context, index) {
          final forecast = forecastToShow[index];
          
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
                  forecast.day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Icon(
                  _getWeatherIcon(forecast.weatherType),
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 5),
                Text(
                  "${forecast.temperature.toStringAsFixed(0)}°C",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  forecast.description.split(' ').first,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<DailyForecast> _getFallbackForecast() {
    return [
      DailyForecast(day: 'Mon', temperature: (_weatherData?.temperature ?? 20) + 1, weatherType: _currentWeather, description: 'Similar', date: DateTime.now()),
      DailyForecast(day: 'Tue', temperature: (_weatherData?.temperature ?? 20) + 2, weatherType: _currentWeather, description: 'Similar', date: DateTime.now()),
      DailyForecast(day: 'Wed', temperature: (_weatherData?.temperature ?? 20) + 1, weatherType: _currentWeather, description: 'Similar', date: DateTime.now()),
      DailyForecast(day: 'Thu', temperature: (_weatherData?.temperature ?? 20) - 1, weatherType: _currentWeather, description: 'Similar', date: DateTime.now()),
      DailyForecast(day: 'Fri', temperature: (_weatherData?.temperature ?? 20) + 2, weatherType: _currentWeather, description: 'Similar', date: DateTime.now()),
      DailyForecast(day: 'Sat', temperature: (_weatherData?.temperature ?? 20) + 3, weatherType: _currentWeather, description: 'Similar', date: DateTime.now()),
      DailyForecast(day: 'Sun', temperature: (_weatherData?.temperature ?? 20) + 1, weatherType: _currentWeather, description: 'Similar', date: DateTime.now()),
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