

// import 'package:flutter/material.dart';
// import 'splash_screen.dart';
// import 'onboarding_screen.dart';
// import 'auth_screen.dart';
// import 'home_page.dart';
// import 'forgot_password_screen.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// void main() {
//   runApp(const YuccaAgroApp());
// }

// class YuccaAgroApp extends StatelessWidget {
//   const YuccaAgroApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "Yucca Consulting Agro App",
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//         fontFamily: 'Roboto',
//       ),

//       // Start with splash screen
//       initialRoute: '/splash',

//       // Named routes
//       routes: {
//         '/splash': (context) => const SplashScreen(),
//         '/onboarding': (context) => const OnboardingScreen(),
//         '/auth': (context) => const AuthScreen(),
//         '/home': (context) => const HomePage(),
//         '/forgotpassword': (context) => const ForgotPasswordScreen(),
//       },
//     );
//   }
// }

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import your screen files
import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'auth_screen.dart';
import 'home_page.dart';
import 'forgot_password_screen.dart';

// ✅ main() must be async to load .env before runApp()
void main() async {
  // ✅ Step 1: Ensure Flutter bindings are initialized (required for async in main)
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Step 2: Load .env file BEFORE running the app
  // For Web: Make sure .env is also in the web/ folder
  await dotenv.load(fileName: ".env");
  
  // ✅ Step 3: Now run the app
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
        primaryColor: const Color(0xFF366000), // ✅ Your custom green
        scaffoldBackgroundColor: const Color(0xFFF5E9CF), // ✅ Your cream background
        fontFamily: 'Roboto',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF366000),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
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

      // Fallback route for unknown paths
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
        );
      },
    );
  }
}