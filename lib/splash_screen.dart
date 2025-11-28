

import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_screen.dart'; // import your onboarding screens file

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Color bgFirst = const Color.fromARGB(255, 215, 223, 216); // soft light green

  @override
  void initState() {
    super.initState();
    // Navigate to onboarding after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgFirst, // light green background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo.png", // your splash image/logo
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              "Yucca Agro",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF366000), // same green as logo
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
