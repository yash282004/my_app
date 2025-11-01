import 'package:flutter/material.dart';
import 'main_weather_screen.dart';
import 'forecast_screen.dart';
import 'favorites_screen.dart';
import 'dart:ui';

void main() {
  runApp(const WeatherStoryboardApp());
}

class WeatherStoryboardApp extends StatelessWidget {
  const WeatherStoryboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Storyboard',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  String _currentCity = "New York"; // Shared city state

  // Remove the _screens list and create screens dynamically

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home Screen - always created with current city
          MainWeatherScreen(
            currentCity: _currentCity,
            onCityChanged: (city) {
              setState(() {
                _currentCity = city;
              });
            },
          ),
          // Forecast Screen - always created with current city
          ForecastScreen(currentCity: _currentCity),
          // Favorites Screen
          const FavoritesScreen(),
        ],
      ),
      bottomNavigationBar: GlassmorphicBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class GlassmorphicBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlassmorphicBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: const Color.fromARGB(0, 255, 255, 255).withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color.fromARGB(0, 255, 255, 255).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.calendar_today, 'Forecast', 1),
                _buildNavItem(Icons.favorite, 'Favorites', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white70,
                size: isSelected ? 28 : 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}