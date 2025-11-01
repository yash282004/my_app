import 'package:flutter/material.dart';
import 'main_weather_screen.dart';

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
      home: const MainWeatherScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}