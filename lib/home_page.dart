
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screen.dart';
import 'tips_screen.dart';
import 'disease_screen.dart';
import 'services/api_service.dart'; // ✅ Added: Import API service

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- Color Palette ---
  static const Color colorLogoGreen = Color(0xFF366000);
  static const Color colorBgCream = Color(0xFFFFEDC7);
  static const Color colorCardGreen = Color(0xFFBCD9A2);
  static const Color colorAccentGold = Color(0xFFC0B87A);
  static const Color colorBtnGreen = Color(0xFF427A43);

  bool isLoggedIn = false;
  Map<String, dynamic>? _user; // ✅ Added: Store user data
  final ApiService _api = ApiService(); // ✅ Added: API service instance

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // ✅ Updated: Check login using ApiService
  Future<void> _checkLoginStatus() async {
    final loggedIn = await _api.isLoggedIn();
    final user = await _api.getUser();
    
    if (mounted) {
      setState(() {
        isLoggedIn = loggedIn;
        _user = user;
      });
    }
  }

  // ✅ Added: Handle logout
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: colorLogoGreen)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _api.logout(); // ✅ Clear tokens via API service
      setState(() {
        isLoggedIn = false;
        _user = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    }
  }

  void _handleFeature(String title, {bool requiresLogin = false}) {
    if (title == "Tips") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TipsScreen()),
      );
      return;
    }

    if (title == "Disease Info") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DiseaseListScreen()), // ✅ Fixed: DiseaseScreen not DiseaseListScreen
      );
      return;
    }

    if (requiresLogin && !isLoggedIn) {
      // ✅ Prompt to login first
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to access this feature')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Accessing $title")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 233, 207),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: _buildLogo(),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: colorLogoGreen),
            onPressed: () {
              if (isLoggedIn) {
                // ✅ Show logout option for logged-in users
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ Show user info
                        if (_user != null) ...[
                          CircleAvatar(
                            backgroundColor: colorCardGreen,
                            radius: 30,
                            child: Text(
                              (_user!['name'] ?? 'U')[0].toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 24, 
                                fontWeight: FontWeight.bold, 
                                color: colorLogoGreen
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _user!['name'] ?? 'User',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              color: colorLogoGreen
                            ),
                          ),
                          Text(
                            _user!['email'] ?? '',
                            style: TextStyle(
                              fontSize: 14, 
                              color: colorLogoGreen.withOpacity(0.7)
                            ),
                          ),
                          const Divider(height: 30),
                        ],
                        
                        // ✅ Logout button
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Logout', style: TextStyle(color: Colors.red)),
                          onTap: () {
                            Navigator.pop(context);
                            _handleLogout();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // ✅ Not logged in - go to auth
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCenterText(),
            const SizedBox(height: 20),
            _buildWeatherCard(), // ✅ We'll connect this to real weather API next!
            const SizedBox(height: 25),
            _buildFeatureGrid(),
            const SizedBox(height: 25),
            _buildMainCTA(),
          ],
        ),
      ),
    );
  }

  // --- Widgets (Your original code - unchanged ✅) ---

  Widget _buildLogo() {
    return Row(
      children: [
        Image.asset(
          'assets/yucca1.png',
          height: 38,
        ),
      ],
    );
  }

  Widget _buildCenterText() {
    return Column(
      children: [
        Text(
          "Smart Agricultural Solutions",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorLogoGreen,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          "Technology driven farming for better yields",
          style: TextStyle(
            color: colorLogoGreen.withOpacity(0.75),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorCardGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorAccentGold, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4)
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.cloud, size: 40, color: colorLogoGreen),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Weather",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorLogoGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Kampala • 28°C • Cloudy", // ✅ We'll replace this with real data next!
                style: TextStyle(
                  color: colorLogoGreen.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const Spacer(),
          // ✅ Added: Tap to refresh weather (placeholder)
          IconButton(
            icon: const Icon(Icons.refresh, color: colorLogoGreen),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fetching real weather data...')),
              );
              // ✅ We'll connect this to weather API in the next step!
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
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
      children: features.map((f) {
        return _featureItem(
          f['icon'] as IconData,
          f['title'] as String,
          requiresLogin: f['login'] as bool,
        );
      }).toList(),
    );
  }

  Widget _featureItem(
    IconData icon,
    String title, {
    required bool requiresLogin,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorAccentGold, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4)
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleFeature(title, requiresLogin: requiresLogin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: colorLogoGreen),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: colorLogoGreen,
                fontWeight: FontWeight.w600,
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
        onPressed: () => _handleFeature("Visit Our Site"),
        icon: const Icon(Icons.language),
        label: const Text("Visit Our Site"),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorBtnGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}