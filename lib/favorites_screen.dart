import 'package:flutter/material.dart';
import 'glassmorphic_container.dart';
import 'weather_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class FavoriteCity {
  final String name;
  double? temperature;
  WeatherType? weatherType;
  String? description;
  bool isLoading;

  FavoriteCity({
    required this.name,
    this.temperature,
    this.weatherType,
    this.description,
    this.isLoading = false,
  });
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<FavoriteCity> _favoriteCities = [
    FavoriteCity(name: 'New York'),
    FavoriteCity(name: 'London'),
    FavoriteCity(name: 'Tokyo'),
    FavoriteCity(name: 'Paris'),
    FavoriteCity(name: 'Sydney'),
  ];
  
  final TextEditingController _cityController = TextEditingController();
  bool _isDarkTheme = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllCitiesWeather();
  }

  void _loadAllCitiesWeather() async {
    setState(() {
      _isLoading = true;
    });

    for (var city in _favoriteCities) {
      await _fetchCityWeather(city);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchCityWeather(FavoriteCity city) async {
    final index = _favoriteCities.indexWhere((c) => c.name == city.name);
    if (index != -1) {
      setState(() {
        _favoriteCities[index].isLoading = true;
      });

      try {
        final weatherData = await WeatherService.fetchWeatherData(city.name);
        setState(() {
          _favoriteCities[index].temperature = weatherData.temperature;
          _favoriteCities[index].weatherType = weatherData.weatherType;
          _favoriteCities[index].description = weatherData.description;
          _favoriteCities[index].isLoading = false;
        });
      } catch (e) {
        print('Error fetching weather for ${city.name}: $e');
        setState(() {
          _favoriteCities[index].isLoading = false;
          _favoriteCities[index].temperature = 20.0;
          _favoriteCities[index].weatherType = WeatherType.sunny;
          _favoriteCities[index].description = 'Unable to load';
        });
      }
    }
  }

  void _addCity() {
    final cityName = _cityController.text.trim();
    if (cityName.isNotEmpty && !_favoriteCities.any((city) => city.name == cityName)) {
      final newCity = FavoriteCity(name: cityName);
      setState(() {
        _favoriteCities.add(newCity);
        _cityController.clear();
      });
      _fetchCityWeather(newCity);
    }
  }

  void _removeCity(String cityName) {
    setState(() {
      _favoriteCities.removeWhere((city) => city.name == cityName);
    });
  }

  void _refreshCityWeather(String cityName) {
    final city = _favoriteCities.firstWhere((c) => c.name == cityName);
    _fetchCityWeather(city);
  }

  Color _getPrimaryColor() {
    return _isDarkTheme ? const Color(0xFF64B5F6) : Color(0xFF2196F3);
  }

  List<Color> _getBackgroundGradient() {
    return _isDarkTheme 
        ? [const Color(0xFF0D47A1), Color(0xFF1976D2)]
        : [const Color(0xFF87CEEB), Color(0xFF1E90FF)];
  }

  IconData _getWeatherIcon(WeatherType? type) {
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
      default:
        return Icons.device_unknown;
    }
  }

  Color _getWeatherColor(WeatherType? type) {
    if (type == null) return Colors.grey;
    
    switch (type) {
      case WeatherType.sunny:
        return Colors.orange;
      case WeatherType.cloudy:
        return Colors.blueGrey;
      case WeatherType.rainy:
        return Colors.blue;
      case WeatherType.snowy:
        return Colors.cyan;
      case WeatherType.windy:
        return Colors.green;
    }
  }

  String _getWeatherLabel(WeatherType? type) {
    if (type == null) return 'Unknown';
    
    switch (type) {
      case WeatherType.sunny:
        return 'Sunny';
      case WeatherType.cloudy:
        return 'Cloudy';
      case WeatherType.rainy:
        return 'Rainy';
      case WeatherType.snowy:
        return 'Snowy';
      case WeatherType.windy:
        return 'Windy';
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      bottom: true, // This ensures space for bottom navigation
      child: Stack(
        children: [
          // Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _getBackgroundGradient(),
              ),
            ),
          ),

          // Content
          Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 20),

              // Add City Section
              _buildAddCitySection(),
              const SizedBox(height: 20),

              // Favorites List
              _buildFavoritesList(),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 80,
        borderRadius: 25,
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Favorite Cities',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Loading weather data...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddCitySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: "Add a city to favorites...",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: _addCity,
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

  Widget _buildFavoritesList() {
    return Expanded(
      child: _favoriteCities.isEmpty ? _buildEmptyState() : _buildCitiesList());
  }

  Widget _buildEmptyState() {
    return Center(
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 200,
        borderRadius: 25,
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
              Icons.favorite_border,
              color: Colors.white70,
              size: 50,
            ),
            const SizedBox(height: 20),
            Text(
              'No favorite cities yet',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add cities to see them here',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCitiesList() {
  return ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).copyWith(
      bottom: 20, // Added extra bottom padding
    ),
    itemCount: _favoriteCities.length,
    itemBuilder: (context, index) {
      final city = _favoriteCities[index];
      return _buildCityCard(city, index);
    },
  );
}

  Widget _buildCityCard(FavoriteCity city, int index) {
  return GlassmorphicContainer(
    width: double.infinity,
    height: 140, // Reduced height from 120 to 100
    borderRadius: 25,
    blur: 20,
    border: 2,
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
        Colors.white.withOpacity(0.4),
        Colors.white.withOpacity(0.1),
      ],
    ),
    margin: const EdgeInsets.only(bottom: 12), // Reduced margin
    child: Padding(
      padding: const EdgeInsets.all(12), // Reduced padding
      child: Row(
        children: [
          // Weather Icon Section
          Container(
            width: 60, // Reduced from 70
            height: 60, // Reduced from 70
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getWeatherColor(city.weatherType).withOpacity(0.4),
                  _getWeatherColor(city.weatherType).withOpacity(0.2),
                ],
              ),
            ),
            child: city.isLoading
                ? Center(
                    child: SizedBox(
                      width: 20, // Reduced
                      height: 20, // Reduced
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      _getWeatherIcon(city.weatherType),
                      color: Colors.white,
                      size: 28, // Reduced from 32
                    ),
                  ),
          ),
          
          const SizedBox(width: 12), // Reduced spacing
          
          // City and Weather Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  city.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18, // Reduced from 20
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2), // Reduced spacing
                if (city.isLoading)
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12, // Reduced
                    ),
                  )
                else if (city.temperature != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${city.temperature!.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Reduced from 18
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1), // Reduced spacing
                      Text(
                        '${_getWeatherLabel(city.weatherType)} • ${city.description ?? ""}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11, // Reduced from 12
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                else
                  Text(
                    'Weather unavailable',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12, // Reduced
                    ),
                  ),
              ],
            ),
          ),
          
          // Action Buttons - Made more compact
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Refresh Button
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white70,
                  size: 18, // Reduced
                ),
                padding: const EdgeInsets.all(4), // Reduced padding
                constraints: const BoxConstraints(
                  minWidth: 36, // Reduced
                  minHeight: 36, // Reduced
                ),
                onPressed: () => _refreshCityWeather(city.name),
                tooltip: 'Refresh weather',
              ),
              
              // Remove Button
              IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: Colors.red[300],
                  size: 18, // Reduced from 24
                ),
                padding: const EdgeInsets.all(4), // Reduced padding
                constraints: const BoxConstraints(
                  minWidth: 36, // Reduced
                  minHeight: 36, // Reduced
                ),
                onPressed: () => _removeCity(city.name),
                tooltip: 'Remove from favorites',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}