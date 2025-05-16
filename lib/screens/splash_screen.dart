// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  // Function to navigate to the login screen after a certain duration
  Future<void> _navigateToLogin() async {
    // Show the splash screen for 2 seconds.
    // In a real app, you can perform initial data loading, settings checks, etc., here.
    await Future.delayed(const Duration(seconds: 2));

    // Navigate after checking if the widget is still mounted
    if (mounted) {
      // Navigate to the '/login' route and remove the current splash screen from the stack
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color backgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.grey.shade100 // Light mode background color (or color matching design)
        : Colors.grey.shade900; // Dark mode background color (or color matching design)

    return Scaffold(
      backgroundColor: backgroundColor, // Set background color
      body: Center( // Center all content on the screen
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: <Widget>[
            // 1. Egg image
            Image.asset(
              'assets/images/egg.png', // Asset path
              width: 200, // Adjust image width (to desired size)
              height: 200, // Adjust image height
              // fit: BoxFit.contain, // Maintain aspect ratio and fill (optional)
            ),
            const SizedBox(height: 30), // Space between image and text

            // 2. Phrase "Travel local,"
            Text(
              'Travel Local',
              textAlign: TextAlign.center, // Center text horizontally
              style: textTheme.headlineMedium?.copyWith( // Can adjust headlineSmall or titleLarge etc.
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground.withOpacity(0.8), // Text color matching the theme
              ),
            ),
            const SizedBox(height: 8), // Space between phrases

            // 3. Phrase "Connect Deeper."
            Text(
              'Connect Deeper',
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}