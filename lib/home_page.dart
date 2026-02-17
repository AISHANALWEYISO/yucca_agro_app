


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screen.dart';
// import 'package:url_launcher/url_launcher.dart'; // Uncomment if implementing web launch

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- Color Palette ---
  static const Color colorLogoGreen = Color(0xFF366000);   // Logo & Icons
  static const Color colorBgCream = Color(0xFFFFEDC7);     // Scaffold Background
  static const Color colorCardGreen = Color(0xFFBCD9A2);   // Weather Card
  static const Color colorAccentGold = Color(0xFFC0B87A);  // Accents/Borders
  static const Color colorBtnGreen = Color(0xFF427A43);    // Visit Site Button
  // static const Color colorBtnOlive = Color(0xFF6B7445); // Alternative Button

  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  // --- Navigate to feature, redirect to Auth if login required
  void _handleFeature(String title, {bool requiresLogin = false}) {
    if (requiresLogin && !isLoggedIn) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      return;
    }

    // Demo action: show snackbar
    // For "Visit Our Site", you would typically launch a URL here
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Accessing $title")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBgCream, // #FFEDC7
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent to blend with bg
        elevation: 0,
        centerTitle: true,
        title: _buildLogo(), // Replaces "Yucca Consulting Ltd" text
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: colorLogoGreen),
            onPressed: () {
              if (isLoggedIn) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile Page Coming Soon")));
              } else {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const AuthScreen()));
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 20),
            _buildWeatherCard(),
            const SizedBox(height: 25),
            _buildFeatureGrid(),
            const SizedBox(height: 25),
            _buildMainCTA(),
          ],
        ),
      ),
    );
  }

  // --- Widgets

  // Logo Widget
  Widget _buildLogo() {
    // TODO: Replace this Icon with your actual logo image
    // Example: Image.asset('assets/logo.png', height: 40, color: colorLogoGreen)
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Using an Icon as a placeholder for the logo with color #366000
        Icon(Icons.eco, color: colorLogoGreen, size: 32), 
        // If you have text next to logo, keep it small, otherwise just icon
        // const SizedBox(width: 8),
        // const Text("Yucca", style: TextStyle(color: colorLogoGreen, fontWeight: FontWeight.bold))
      ],
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Good Morning ",
            style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold,
                color: colorLogoGreen // #366000
            )),
        const SizedBox(height: 4),
        Text("Smart agricultural solutions for you",
            style: TextStyle(color: colorLogoGreen.withOpacity(0.8))),
      ],
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorCardGreen, // #BCD9A2
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorAccentGold, width: 1), // #C0B87A
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(Icons.cloud, size: 40, color: colorLogoGreen),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Today's Weather",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorLogoGreen
                  )),
              const SizedBox(height: 4),
              Text("Kampala • 28°C • Cloudy",
                  style: TextStyle(color: colorLogoGreen.withOpacity(0.8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    // The 6 specific cards requested
    final features = [
      {'icon': Icons.cloud, 'title': 'Weather', 'login': false},
      {'icon': Icons.lightbulb_outline, 'title': 'Tips', 'login': false},
      {'icon': Icons.bug_report, 'title': 'Disease Info', 'login': false},
      {'icon': Icons.eco, 'title': 'Crop Advice', 'login': true},
      {'icon': Icons.stars, 'title': 'Recommendations', 'login': true},
      {'icon': Icons.assessment, 'title': 'Reports', 'login': true},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: features
          .map((f) => _featureItem(
                f['icon'] as IconData,
                f['title'] as String,
                requiresLogin: f['login'] as bool,
              ))
          .toList(),
    );
  }

  Widget _featureItem(IconData icon, String title, {required bool requiresLogin}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // White cards pop against #FFEDC7 background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorAccentGold, width: 1), // #C0B87A Border
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleFeature(title, requiresLogin: requiresLogin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: colorLogoGreen), // #366000
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: colorLogoGreen,
                fontWeight: FontWeight.w600
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCTA() {
    return SizedBox(
      height: 55,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Optional: Launch URL if you add url_launcher package
          // launchUrl(Uri.parse("https://yuccaconsult.com"));
          _handleFeature("Visit Our Site", requiresLogin: false);
        },
        icon: const Icon(Icons.language),
        label: const Text("Visit Our Site"),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorBtnGreen, // #427A43
          foregroundColor: Colors.white, // White text for contrast
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
      ),
    );
  }
}