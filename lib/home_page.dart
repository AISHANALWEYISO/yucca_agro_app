import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'tips_screen.dart';
import 'disease_screen.dart';
import 'services/api_service.dart';
import 'soilscanner_screen.dart';
import 'weather_screen.dart';
import 'crop_calendar_screen.dart';
import 'market_screen.dart';
import 'reports_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color colorLogoGreen = Color(0xFF366000);
  static const Color colorCardGreen = Color(0xFFBCD9A2);
  static const Color colorBtnGreen = Color(0xFF427A43);

  bool isLoggedIn = false;
  Map<String, dynamic>? _user;
  final ApiService _api = ApiService();

  String _weatherText = 'Tap to load weather';
  String _weatherCity = 'Kampala';
  bool _weatherLoading = false;
  IconData _weatherIcon = Icons.cloud;

  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:5001/api';
    try {
      if (Platform.isAndroid) return 'http://192.168.1.241:5001/api'; // ✅ Updated IP
    } catch (_) {}
    return 'http://127.0.0.1:5001/api';
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchWeather();
  }

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

  Future<void> _fetchWeather() async {
    setState(() => _weatherLoading = true);
    try {
      final uri = Uri.parse('$baseUrl/weather?city=$_weatherCity');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temp = (data['temperature'] as num).toStringAsFixed(0);
        final desc = data['description'] ?? '';
        final city = data['city'] ?? _weatherCity;
        final humidity = data['humidity'] ?? '--';
        setState(() {
          _weatherText = '$city • ${temp}°C • ${_capitalize(desc)} • 💧$humidity%';
          _weatherIcon = _getWeatherIcon(desc);
        });
      } else {
        setState(() => _weatherText = 'Weather unavailable');
      }
    } catch (_) {
      setState(() => _weatherText = 'Could not fetch weather');
    } finally {
      setState(() => _weatherLoading = false);
    }
  }

  IconData _getWeatherIcon(String description) {
    final d = description.toLowerCase();
    if (d.contains('rain') || d.contains('drizzle')) return Icons.grain;
    if (d.contains('thunder') || d.contains('storm')) return Icons.thunderstorm;
    if (d.contains('snow')) return Icons.ac_unit;
    if (d.contains('mist') || d.contains('fog') || d.contains('haze')) return Icons.foggy;
    if (d.contains('clear') || d.contains('sun')) return Icons.wb_sunny;
    return Icons.cloud;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showLoginRequiredDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: Text('Please login to access $feature'),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colorLogoGreen)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _goToAuth();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorBtnGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

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
      await _api.logout();
      setState(() {
        isLoggedIn = false;
        _user = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    }
  }

  // ✅ FIXED: All titles match EXACTLY (case-sensitive)
  void _handleFeature(String title) {
    switch (title) {
      case 'Weather':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen()));
        break;
        
      case 'Farming Tips':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TipsScreen()));
        break;
        
      case 'Disease Information':  // ✅ Changed from 'Disease Info'
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DiseaseScreen()));
        break;
        
      case 'Crop Calendar':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CropCalendarScreen()));
        break;
        
      case 'Market':  // ✅ Changed from 'Marketplace'
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketScreen()));
        break;
        
      case 'Soil Scanner':
      case 'Reports':
        if (!isLoggedIn) {
          _showLoginRequiredDialog(title);
        } else {
          if (title == 'Soil Scanner') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SoilScannerScreen()));
          } else if (title == 'Reports') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
          }
        }
        break;
        
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title coming soon!')),
        );
    }
  }

  void _goToAuth() {
    Navigator.pushReplacementNamed(context, '/auth')
        .then((_) {
          if (mounted) _checkLoginStatus();
        });
  }

  Future<void> _launchSite() async {
    final uri = Uri.parse('https://yuccaconsult.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E9CF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Yucca Consulting Limited',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: colorLogoGreen,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWeatherCard(),
            const SizedBox(height: 12),
            _buildFeatureGrid(),
            const SizedBox(height: 25),
            _buildVisitSiteButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return GestureDetector(
      onTap: () => _handleFeature('Weather'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D5016), Color(0xFF4A7C2F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF2D5016).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            _weatherLoading
                ? const SizedBox(
                    width: 48,
                    height: 48,
                    child:
                        CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(_weatherIcon, size: 48, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Today's Weather",
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(_weatherText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Tap for full forecast →',
                      style:
                          TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: _weatherLoading ? null : _fetchWeather,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ FIXED: All titles match switch cases EXACTLY
  Widget _buildFeatureGrid() {
    final features = [
      {'icon': Icons.calendar_month, 'title': 'Crop Calendar', 'color': const Color(0xFF27AE60)},
      {'icon': Icons.lightbulb_outline, 'title': 'Farming Tips', 'color': const Color(0xFFE8A838)},
      {'icon': Icons.bug_report, 'title': 'Disease Information', 'color': const Color(0xFFD95B5B)}, // ✅ Changed
      {'icon': Icons.landscape, 'title': 'Soil Scanner', 'color': const Color(0xFF6B8E3E)},
      {'icon': Icons.shopping_bag, 'title': 'Market', 'color': const Color(0xFF3498DB)}, // ✅ Changed
      {'icon': Icons.assessment, 'title': 'Reports', 'color': const Color(0xFF2ECC71)},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: features
          .map((f) => _featureItem(
                f['icon'] as IconData,
                f['title'] as String,
                color: f['color'] as Color,
              ))
          .toList(),
    );
  }

  Widget _featureItem(IconData icon, String title, {required Color color}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _handleFeature(title),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                    fontSize: 13,
                    color: colorLogoGreen,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitSiteButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _launchSite,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorLogoGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
        ),
        child: const Text(
          'Visit Our Site',
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}