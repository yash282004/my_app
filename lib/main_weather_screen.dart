import 'package:flutter/material.dart';
import 'glassmorphic_container.dart';
import 'weather_model.dart';
import 'weather_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MainWeatherScreen extends StatefulWidget {
  final String currentCity;
  final Function(String) onCityChanged;

  const MainWeatherScreen({
    super.key,
    required this.currentCity,
    required this.onCityChanged,
  });

  @override
  State<MainWeatherScreen> createState() => _MainWeatherScreenState();
}

class _MainWeatherScreenState extends State<MainWeatherScreen> {
  WeatherType _currentWeather = WeatherType.sunny;
  bool _isDarkTheme = false;
  WeatherData? _weatherData;
  bool _isLoading = false;
    bool _isLocationLoading = false; // ADD THIS
      String _currentLocationCity = 'Loading...'; // ADD THIS


  String _errorMessage = '';
  List<HourlyForecast> _hourlyData = [];
  

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
  _initializeApp(); // CHANGE THIS LINE
}


  bool _isRainExpectedToday() {
    if (_hourlyData.isEmpty) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check current weather
    if (_currentWeather == WeatherType.rainy) return true;
    
    // Check hourly forecast for today
    for (final hourly in _hourlyData) {
      if (hourly.dateTime.isAfter(now) && 
          hourly.dateTime.day == now.day &&
          hourly.weatherType == WeatherType.rainy) {
        return true;
      }
    }
    
    return false;
  }

Future<void> _initializeApp() async {
  // First try to get current location
  await _getCurrentLocation();
  
  // If location fails, use the provided currentCity or fallback
  if (_currentLocationCity == 'Loading...' || _currentLocationCity.isEmpty) {
    if (widget.currentCity.isNotEmpty) {
      await _fetchWeatherForCity(widget.currentCity);
    } else {
      await _fetchWeatherForCity('New York');
    }
  }
}

Future<void> _getCurrentLocation() async {
  setState(() {
    _isLocationLoading = true;
  });

  try {
    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLocationLoading = false;
          _currentLocationCity = 'Permission denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLocationLoading = false;
        _currentLocationCity = 'Permission permanently denied';
      });
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    // Get city name from coordinates
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      String cityName = placemark.locality ?? 
                       placemark.subAdministrativeArea ?? 
                       placemark.administrativeArea ?? 
                       'Unknown Location';
      
      setState(() {
        _currentLocationCity = cityName;
      });

      // Fetch weather for current location
      await _fetchWeatherForCity(cityName);
    }
  } catch (e) {
    print('Location Error: $e');
    setState(() {
      _currentLocationCity = 'Location unavailable';
      _isLocationLoading = false;
    });
    
    // Fallback to default city
    if (widget.currentCity.isNotEmpty) {
      await _fetchWeatherForCity(widget.currentCity);
    } else {
      await _fetchWeatherForCity('New York');
    }
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
      final hourlyData = await WeatherService.fetchHourlyForecast(cityName);
      
      setState(() {
        _weatherData = weatherData;
        _currentWeather = weatherData.weatherType;
        _hourlyData = hourlyData;
        _isLoading = false;
          _isLocationLoading = false; // ADD THIS LINE

      });
      
      // Update parent with new city
      widget.onCityChanged(cityName);
      
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
        hourlyForecast: [],
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
        hourlyForecast: [],
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
        hourlyForecast: [],
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
        hourlyForecast: [],
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
        hourlyForecast: [],
      ),
    };

    final mockHourly = [
      HourlyForecast(time: 'Now', temperature: 20.0, weatherType: WeatherType.sunny, description: 'Sunny', dateTime: DateTime.now()),
      HourlyForecast(time: '3PM', temperature: 21.0, weatherType: WeatherType.sunny, description: 'Sunny', dateTime: DateTime.now()),
      HourlyForecast(time: '6PM', temperature: 19.0, weatherType: WeatherType.cloudy, description: 'Cloudy', dateTime: DateTime.now()),
      HourlyForecast(time: '9PM', temperature: 17.0, weatherType: WeatherType.cloudy, description: 'Cloudy', dateTime: DateTime.now()),
      HourlyForecast(time: '12AM', temperature: 16.0, weatherType: WeatherType.cloudy, description: 'Cloudy', dateTime: DateTime.now()),
      HourlyForecast(time: '3AM', temperature: 15.0, weatherType: WeatherType.cloudy, description: 'Cloudy', dateTime: DateTime.now()),
      HourlyForecast(time: '6AM', temperature: 14.0, weatherType: WeatherType.sunny, description: 'Sunny', dateTime: DateTime.now()),
      HourlyForecast(time: '9AM', temperature: 16.0, weatherType: WeatherType.sunny, description: 'Sunny', dateTime: DateTime.now()),
      HourlyForecast(time: '12PM', temperature: 18.0, weatherType: WeatherType.sunny, description: 'Sunny', dateTime: DateTime.now()),
    ];

    final cityKey = cityName.toLowerCase();
    setState(() {
      _weatherData = mockData[cityKey] ?? mockData['new york']!;
      _currentWeather = _weatherData!.weatherType;
      _hourlyData = mockHourly;
      _isLoading = false;
        _isLocationLoading = false; // ADD THIS LINE

    });
    
    // Update parent with new city
    widget.onCityChanged(cityName);
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
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: _buildHeader(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // ADD RAIN WARNING HERE
                      if (!_isLoading && _errorMessage.isEmpty) _buildRainWarning(),
                      if (_isLoading) _buildLoadingIndicator()
                      else if (_errorMessage.isNotEmpty) _buildErrorWidget()
                      else _buildWeatherCard(),
                      const SizedBox(height: 20),
                      if (!_isLoading && _errorMessage.isEmpty) _buildQuoteCard(),
                      const SizedBox(height: 20),
                      if (!_isLoading && _errorMessage.isEmpty) _buildHourlyForecast(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
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
  Widget _buildRainWarning() {
    if (!_isRainExpectedToday()) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 70,
        borderRadius: 20,
        blur: 15,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.3),
            Colors.blue.withOpacity(0.1),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.5),
            Colors.blue.withOpacity(0.2),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.umbrella,
              color: Colors.blue[100],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rain Expected Today',
                    style: TextStyle(
                      color: Colors.blue[100],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Don\'t forget to carry an umbrella!',
                    style: TextStyle(
                      color: Colors.blue[100],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.blue[100],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        // Search Bar
        GlassmorphicContainer(
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
              // Location icon button
              IconButton(
                icon: Icon(
                  Icons.my_location,
                  color: _isLocationLoading ? Colors.grey : Colors.white70,
                ),
                onPressed: _isLocationLoading ? null : _getCurrentLocation,
                tooltip: 'Use current location',
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: TextEditingController(text: _weatherData?.cityName ?? _currentLocationCity),
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
              if (_isLocationLoading)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Control Buttons Row
        _buildControlButtons(),
      ],
    ),
  );
}

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Theme Toggle Button
        GlassmorphicContainer(
          width: 120,
          height: 50,
          borderRadius: 15,
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
          child: InkWell(
            onTap: () {
              setState(() {
                _isDarkTheme = !_isDarkTheme;
              });
            },
            borderRadius: BorderRadius.circular(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isDarkTheme ? Icons.nightlight_round : Icons.wb_sunny,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isDarkTheme ? 'Dark' : 'Light',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        //
      ],
    );
  }

  Widget _buildHourlyForecast() {
    final hourlyToShow = _hourlyData.isNotEmpty ? _hourlyData : _getFallbackHourly();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            'Today\'s Forecast',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: hourlyToShow.length,
            itemBuilder: (context, index) {
              final hourly = hourlyToShow[index];
              
              return GlassmorphicContainer(
                width: 70,
                height: 100,
                borderRadius: 15,
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
                margin: EdgeInsets.only(right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hourly.time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Icon(
                      _getWeatherIcon(hourly.weatherType),
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${hourly.temperature.toStringAsFixed(0)}°",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hourly.description.split(' ').first,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
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
        ),
      ],
    );
  }

  List<HourlyForecast> _getFallbackHourly() {
    final baseTemp = _weatherData?.temperature ?? 20;
    return [
      HourlyForecast(time: 'Now', temperature: baseTemp, weatherType: _currentWeather, description: 'Current', dateTime: DateTime.now()),
      HourlyForecast(time: '3PM', temperature: baseTemp + 1, weatherType: _currentWeather, description: 'Similar', dateTime: DateTime.now()),
      HourlyForecast(time: '6PM', temperature: baseTemp - 1, weatherType: _currentWeather, description: 'Similar', dateTime: DateTime.now()),
      HourlyForecast(time: '9PM', temperature: baseTemp - 2, weatherType: _currentWeather, description: 'Similar', dateTime: DateTime.now()),
      HourlyForecast(time: '12AM', temperature: baseTemp - 3, weatherType: _currentWeather, description: 'Similar', dateTime: DateTime.now()),
      HourlyForecast(time: '3AM', temperature: baseTemp - 4, weatherType: _currentWeather, description: 'Similar', dateTime: DateTime.now()),
      HourlyForecast(time: '6AM', temperature: baseTemp - 3, weatherType: _currentWeather, description: 'Similar', dateTime: DateTime.now()),
      HourlyForecast(time: '9AM', temperature: baseTemp - 1, weatherType: _currentWeather, description: 'Similar', dateTime: DateTime.now()),
    ];
  }

  // Keep all other existing methods (buildLoadingIndicator, buildErrorWidget, buildAnimatedBackground, buildWeatherCard, buildWeatherIcon, buildWeatherDetail, buildQuoteCard, getWeatherIcon) exactly the same as before
  // [Include all the remaining methods from your previous main_weather_screen.dart file]

  Widget _buildLoadingIndicator() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    child: GlassmorphicContainer(
      width: double.infinity,
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
            _isLocationLoading 
              ? 'Detecting your location...' 
              : 'Loading weather for ${_weatherData?.cityName ?? _currentLocationCity}...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          if (_isLocationLoading) ...[
            const SizedBox(height: 10),
            const Text(
              'Please allow location access',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

  Widget _buildErrorWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        width: double.infinity,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
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

  Widget _buildWeatherCard() {
    final data = _weatherData!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        width: double.infinity,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        width: double.infinity,
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
      ),
    );
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