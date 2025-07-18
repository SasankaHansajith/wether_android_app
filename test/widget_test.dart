import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cityclime/main.dart';

void main() {
  testWidgets('CityClime app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the loading screen to appear
    await tester.pump();

    // Verify that the loading screen shows "CityClime" text
    expect(find.text('CityClime'), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);

    // Wait for the 3-second timer to complete and navigate to LoginPage
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify that we're now on the LoginPage
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to your account'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Facebook'), findsOneWidget);
  });

  testWidgets('Navigation to Sign Up page works from Login page', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for navigation to LoginPage
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Tap the Sign Up link
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Verify that we're now on the SignUpPage
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Sign up to get started'), findsOneWidget);
  });

  testWidgets('Navigation to Main page works from Login page', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for navigation to LoginPage
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Enter test credentials
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password123');

    // Tap the Login button
    await tester.tap(find.text('Login').last);
    await tester.pumpAndSettle();

    // Verify that we're now on the MainPage
    expect(find.text('Hi! 👋'), findsOneWidget);
    expect(
      find.text('What country\'s weather do you want to check?'),
      findsOneWidget,
    );
  });
}
