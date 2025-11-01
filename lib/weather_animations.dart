import 'package:flutter/material.dart';
import 'weather_model.dart';

class WeatherAnimations extends StatelessWidget {
  final WeatherType weatherType;
  final bool isDarkTheme;

  const WeatherAnimations({
    super.key,
    required this.weatherType,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Weather-specific animations
        _buildWeatherSpecificAnimation(),
        
        // Overlay for readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.05),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherSpecificAnimation() {
    switch (weatherType) {
      case WeatherType.sunny:
        return _buildSunnyAnimation();
      case WeatherType.cloudy:
        return _buildCloudyAnimation();
      case WeatherType.rainy:
        return _buildRainyAnimation();
      case WeatherType.snowy:
        return _buildSnowyAnimation();
      case WeatherType.windy:
        return _buildWindyAnimation();
    }
  }

  Widget _buildSunnyAnimation() {
    return Stack(
      children: [
        // Sun
        Positioned(
          top: 100,
          right: 50,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.yellow.withOpacity(0.8),
                  Colors.orange.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCloudyAnimation() {
    return Stack(
      children: [
        // Cloud 1
        Positioned(
          top: 150,
          left: 50,
          child: Container(
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        // Cloud 2
        Positioned(
          top: 100,
          right: 100,
          child: Container(
            width: 80,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(17.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRainyAnimation() {
    return Stack(
      children: [
        // Simple rain effect
        for (int i = 0; i < 10; i++)
          Positioned(
            left: (i * 40.0),
            top: (i * 20.0),
            child: Container(
              width: 2,
              height: 20,
              color: Colors.blue.withOpacity(0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildSnowyAnimation() {
    return Stack(
      children: [
        // Simple snow effect
        for (int i = 0; i < 15; i++)
          Positioned(
            left: (i * 30.0),
            top: (i * 25.0),
            child: Icon(
              Icons.ac_unit,
              color: Colors.white.withOpacity(0.7),
              size: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildWindyAnimation() {
    return Stack(
      children: [
        // Simple wind lines
        for (int i = 0; i < 8; i++)
          Positioned(
            left: (i * 50.0),
            top: 100 + (i * 40.0),
            child: Container(
              width: 40,
              height: 1,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
      ],
    );
  }
}