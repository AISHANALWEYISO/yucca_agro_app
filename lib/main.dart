
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';


// import 'splash_screen.dart';
// import 'onboarding_screen.dart';
// import 'auth_screen.dart';
// import 'home_page.dart';
// import 'forgot_password_screen.dart';


// void main() async {
//   //  Flutter bindings initialized (required for async in main)
//   WidgetsFlutterBinding.ensureInitialized();
  
  
//   await dotenv.load(fileName: ".env");
  
//   // run the app
//   runApp(const YuccaAgroApp());
// }

// class YuccaAgroApp extends StatelessWidget {
//   const YuccaAgroApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "Yucca Consulting Ltd App",
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//         primaryColor: const Color(0xFF366000), // ✅ Your custom green
//         scaffoldBackgroundColor: const Color(0xFFF5E9CF), // ✅ Your cream background
//         fontFamily: 'Roboto',
//         useMaterial3: true,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Color(0xFF366000),
//           foregroundColor: Colors.white,
//           elevation: 0,
//         ),
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

//       // Fallback route for unknown paths
//       onUnknownRoute: (settings) {
//         return MaterialPageRoute(
//           builder: (context) => const HomePage(),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'auth_screen.dart';
import 'home_page.dart';
import 'forgot_password_screen.dart';
import 'notifications_screen.dart';
import 'feedback_screen.dart';
import 'profile_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const YuccaAgroApp());
}

class YuccaAgroApp extends StatelessWidget {
  const YuccaAgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Yucca Consulting Ltd App",
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF366000),
        scaffoldBackgroundColor: const Color(0xFFF5E9CF),
        fontFamily: 'Roboto',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF366000),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF366000),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const MainNavigationWrapper(), // ✅ Must point here
        '/forgotpassword': (context) => const ForgotPasswordScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/profile': (context) => const ProfileScreen(user: null),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const MainNavigationWrapper(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// ✅ BOTTOM NAVIGATION WRAPPER
// ─────────────────────────────────────────
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  final ApiService _api = ApiService();
  bool _isLoggedIn = false;
  bool _isLoading = true;

  late List<Widget> _screens;

  static const Color colorLogoGreen = Color(0xFF366000);
  static const Color colorBtnGreen = Color(0xFF427A43);

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await _api.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isLoading = false;
        _screens = [
          const HomePage(), // ✅ Home Tab
          loggedIn ? const NotificationsScreen() : _loginRequiredScreen('Updates'),
          loggedIn ? const FeedbackScreen() : _loginRequiredScreen('Feedback'),
          loggedIn ? const ProfileScreen(user: null) : _loginRequiredScreen('Profile'),
        ];
      });
    }
  }

  Widget _loginRequiredScreen(String feature) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '$feature requires login',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/auth');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorBtnGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Login Now'),
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index != 0 && !_isLoggedIn) {
      _showLoginDialog(index);
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _showLoginDialog(int targetIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to access this feature'),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: colorLogoGreen)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/auth').then((_) => _checkLoginStatus());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorBtnGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5E9CF),
        body: Center(
          child: CircularProgressIndicator(color: colorLogoGreen),
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedItemColor: colorLogoGreen,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Updates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback_outlined),
            activeIcon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}