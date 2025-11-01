import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherStoryboardApp());
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('Basic UI elements are present', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherStoryboardApp());
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}