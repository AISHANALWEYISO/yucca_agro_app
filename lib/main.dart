

import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'auth_screen.dart';
import 'home_page.dart';
import 'forgot_password_screen.dart';

void main() {
  runApp(const YuccaAgroApp());
}

class YuccaAgroApp extends StatelessWidget {
  const YuccaAgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Yucca Consulting Agro App",
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),

      // Start with splash screen
      initialRoute: '/splash',

      // Named routes
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomePage(),
        '/forgotpassword': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}
