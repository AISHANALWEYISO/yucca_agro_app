

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'auth_screen.dart';
// import 'tips_screen.dart';


// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   // --- Color Palette ---
//   static const Color colorLogoGreen = Color(0xFF366000);   // Logo & Icons
//   static const Color colorBgCream = Color(0xFFFFEDC7);     // Scaffold Background
//   static const Color colorCardGreen = Color(0xFFBCD9A2);   // Weather Card
//   static const Color colorAccentGold = Color(0xFFC0B87A);  // Accents/Borders
//   static const Color colorBtnGreen = Color(0xFF427A43);    // Visit Site Button

//   bool isLoggedIn = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//     });
//   }

//   void _handleFeature(String title, {bool requiresLogin = false}) {
//     if (requiresLogin && !isLoggedIn) {
//       Navigator.push(
//           context, MaterialPageRoute(builder: (_) => const AuthScreen()));
//       return;
//     }

//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text("Accessing $title")));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: colorBgCream,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: false,
//         title: _buildLogo(),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_outline, color: colorLogoGreen),
//             onPressed: () {
//               if (isLoggedIn) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Profile Coming Soon")));
//               } else {
//                 Navigator.push(
//                     context, MaterialPageRoute(builder: (_) => const AuthScreen()));
//               }
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             _buildCenterText(),
//             const SizedBox(height: 20),
//             _buildWeatherCard(),
//             const SizedBox(height: 25),
//             _buildFeatureGrid(),
//             const SizedBox(height: 25),
//             _buildMainCTA(),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- Widgets

//   // Logo Widget (LEFT)
//   Widget _buildLogo() {
//     return Row(
//       children: [
//         Image.asset(
//           'assets/yucca1.png',
//           height: 38,
//         ),
//       ],
//     );
//   }

//   // Center Text
//   Widget _buildCenterText() {
//     return Column(
//       children: [
//         Text(
//           "Smart Agricultural Solutions",
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: colorLogoGreen,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 6),
//         Text(
//           "Technology driven farming for better yields",
//           style: TextStyle(
//             color: colorLogoGreen.withOpacity(0.75),
//             fontSize: 14,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildWeatherCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: colorCardGreen,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: colorAccentGold, width: 1),
//         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.cloud, size: 40, color: colorLogoGreen),
//           const SizedBox(width: 15),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Today's Weather",
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold, color: colorLogoGreen)),
//               const SizedBox(height: 4),
//               Text("Kampala • 28°C • Cloudy",
//                   style: TextStyle(
//                       color: colorLogoGreen.withOpacity(0.8))),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeatureGrid() {
//     final features = [
//       {'icon': Icons.cloud, 'title': 'Weather', 'login': false},
//       {'icon': Icons.lightbulb_outline, 'title': 'Tips', 'login': false},
//       {'icon': Icons.bug_report, 'title': 'Disease Info', 'login': false},
//       {'icon': Icons.eco, 'title': 'Crop Advice', 'login': true},
//       {'icon': Icons.stars, 'title': 'Recommendations', 'login': true},
//       {'icon': Icons.assessment, 'title': 'Reports', 'login': true},
//     ];

//     return GridView.count(
//       crossAxisCount: 2,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisSpacing: 12,
//       mainAxisSpacing: 12,
//       children: features
//           .map((f) => _featureItem(
//                 f['icon'] as IconData,
//                 f['title'] as String,
//                 requiresLogin: f['login'] as bool,
//               ))
//           .toList(),
//     );
//   }

//   Widget _featureItem(IconData icon, String title,
//       {required bool requiresLogin}) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: colorAccentGold, width: 1),
//         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: () => _handleFeature(title, requiresLogin: requiresLogin),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: colorLogoGreen),
//             const SizedBox(height: 10),
//             Text(
//               title,
//               style: TextStyle(
//                   fontSize: 16,
//                   color: colorLogoGreen,
//                   fontWeight: FontWeight.w600),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMainCTA() {
//     return SizedBox(
//       height: 55,
//       width: double.infinity,
//       child: ElevatedButton.icon(
//         onPressed: () => _handleFeature("Visit Our Site"),
//         icon: const Icon(Icons.language),
//         label: const Text("Visit Our Site"),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: colorBtnGreen,
//           foregroundColor: Colors.white,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           elevation: 4,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screen.dart';
import 'tips_screen.dart';
import 'disease_screen.dart';

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
      MaterialPageRoute(builder: (_) => const DiseaseListScreen()),
    );
    return;
  }

  if (requiresLogin && !isLoggedIn) {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile Coming Soon")),
                );
              } else {
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

  // --- Widgets ---

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
                "Kampala • 28°C • Cloudy",
                style: TextStyle(
                  color: colorLogoGreen.withOpacity(0.8),
                ),
              ),
            ],
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
