// test/widget_test.dart (Simplified)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';  // Use your actual package name
import 'package:my_app/main_weather_screen.dart';  // Use your actual package name




void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const WeatherStoryboardApp());

    // Verify the app starts successfully
    expect(find.byType(MainWeatherScreen), findsOneWidget);
  });

  testWidgets('Basic UI elements are present', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherStoryboardApp());

    // Check for main UI components
    expect(find.text('New York'), findsOneWidget);
    expect(find.text('22°C'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Can change city name', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherStoryboardApp());

    // Find and interact with search field
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Paris');
    await tester.pump();

    expect(find.text('Paris'), findsOneWidget);
  });
}