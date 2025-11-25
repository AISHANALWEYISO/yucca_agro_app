

import 'package:flutter/material.dart';
import 'splash_screen.dart';

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
      home: SplashScreen(),
    );
  }
}
