import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

// model
class CurrentWeather {
  final String city;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final String description;
  final String icon;
  final double windSpeed;
  final int pressure;
  final int visibility;

  CurrentWeather.fromJson(Map<String, dynamic> j)
      : city = j['city'],
        country = j['country'],
        temperature = (j['temperature'] as num).toDouble(),
        feelsLike = (j['feels_like'] as num).toDouble(),
        tempMin = (j['temp_min'] as num).toDouble(),
        tempMax = (j['temp_max'] as num).toDouble(),
        humidity = j['humidity'],
        description = j['description'],
        icon = j['icon'],
        windSpeed = (j['wind_speed'] as num).toDouble(),
        pressure = j['pressure'],
        visibility = j['visibility'];
}

class DayForecast {
  final String date;
  final double tempMax;
  final double tempMin;
  final double temperature;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int rainChance;

  DayForecast.fromJson(Map<String, dynamic> j)
      : date = j['date'],
        tempMax = (j['temp_max'] as num).toDouble(),
        tempMin = (j['temp_min'] as num).toDouble(),
        temperature = (j['temperature'] as num).toDouble(),
        description = j['description'],
        icon = j['icon'],
        humidity = j['humidity'],
        windSpeed = (j['wind_speed'] as num).toDouble(),
        rainChance = j['rain_chance'];
}

// weather screen

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  // Colors
  static const Color deepGreen = Color(0xFF1B3A0F);
  static const Color midGreen = Color(0xFF2D5A1B);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color cream = Color(0xFFF5EDD6);
  static const Color gold = Color(0xFFD4A843);

  CurrentWeather? _current;
  List<DayForecast> _forecast = [];
  bool _loading = false;
  String? _error;
  String _city = 'Kampala';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:5001/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5001/api';
    } catch (_) {}
    return 'http://127.0.0.1:5001/api';
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _fetchAll();
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    _animController.reset();

    try {
      final results = await Future.wait([
        http.get(Uri.parse('$baseUrl/weather?city=$_city')),
        http.get(Uri.parse('$baseUrl/weather/forecast?city=$_city')),
      ]).timeout(const Duration(seconds: 15));

      if (results[0].statusCode == 200 && results[1].statusCode == 200) {
        final currentData = jsonDecode(results[0].body);
        final forecastData = jsonDecode(results[1].body);

        setState(() {
          _current = CurrentWeather.fromJson(currentData);
          _forecast = (forecastData['forecast'] as List)
              .map((e) => DayForecast.fromJson(e))
              .toList();
        });
        _animController.forward();
      } else {
        setState(() => _error = 'Could not find weather for "$_city"');
      }
    } catch (e) {
      setState(() => _error = 'Connection failed. Is Flask running?');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _search() {
    final city = _searchController.text.trim();
    if (city.isNotEmpty) {
      setState(() => _city = city);
      _fetchAll();
    }
  }

  // ─── Weather icon emoji ───
  String _weatherEmoji(String description) {
    final d = description.toLowerCase();
    if (d.contains('thunder')) return '⛈️';
    if (d.contains('drizzle')) return '🌦️';
    if (d.contains('rain')) return '🌧️';
    if (d.contains('snow')) return '❄️';
    if (d.contains('mist') || d.contains('fog') || d.contains('haze'))
      return '🌫️';
    if (d.contains('cloud')) return '☁️';
    if (d.contains('clear') || d.contains('sun')) return '☀️';
    return '🌤️';
  }

  // ─── Day name from date string ───
  String _dayName(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    if (date.day == now.day) return 'Today';
    if (date.day == now.add(const Duration(days: 1)).day) return 'Tomorrow';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  // ─── Background gradient based on weather ───
  List<Color> _bgGradient(String description) {
    final d = description.toLowerCase();
    if (d.contains('rain') || d.contains('drizzle')) {
      return [const Color(0xFF1A2A3A), const Color(0xFF2C4A5A)];
    }
    if (d.contains('thunder')) {
      return [const Color(0xFF1A1A2E), const Color(0xFF2D1B4E)];
    }
    if (d.contains('cloud')) {
      return [const Color(0xFF1B3A1F), const Color(0xFF2D5A30)];
    }
    if (d.contains('clear') || d.contains('sun')) {
      return [const Color(0xFF1B3A0F), const Color(0xFF2E6B1A)];
    }
    return [deepGreen, midGreen];
  }

  @override
  Widget build(BuildContext context) {
    final bgColors = _current != null
        ? _bgGradient(_current!.description)
        : [deepGreen, midGreen];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _loading
              ? _buildLoading()
              : _error != null
                  ? _buildError()
                  : _buildContent(),
        ),
      ),
    );
  }

  // ─── Loading ───
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          const SizedBox(height: 16),
          Text('Fetching weather...',
              style: TextStyle(color: Colors.white.withOpacity(0.7))),
        ],
      ),
    );
  }

  // ─── Error ───
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(_error!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchAll,
              style: ElevatedButton.styleFrom(
                  backgroundColor: lightGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Main Content ───
  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 8),
            _buildCurrentWeather(),
            const SizedBox(height: 16),
            _buildWeatherStats(),
            const SizedBox(height: 16),
            _buildForecast(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Header ───
  Widget _buildHeader() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final dateStr =
        '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 12)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _current != null
                          ? '${_current!.city}, ${_current!.country}'
                          : _city,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Refresh
          GestureDetector(
            onTap: _fetchAll,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search Bar ───
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search any city...',
                  hintStyle:
                      TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (_) => _search(),
              ),
            ),
            GestureDetector(
              onTap: _search,
              child: Container(
                margin: const EdgeInsets.all(6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Go',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Current Weather ───
  Widget _buildCurrentWeather() {
    if (_current == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            // Big emoji
            Text(
              _weatherEmoji(_current!.description),
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 12),
            // Temperature
            Text(
              '${_current!.temperature.toStringAsFixed(0)}°C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.w200,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              _capitalize(_current!.description),
              style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 20,
                  fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 8),
            // Min / Max
            Text(
              'H: ${_current!.tempMax.toStringAsFixed(0)}°  •  L: ${_current!.tempMin.toStringAsFixed(0)}°',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Weather Stats ───
  Widget _buildWeatherStats() {
    if (_current == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statCard('💧', 'Humidity', '${_current!.humidity}%'),
          const SizedBox(width: 12),
          _statCard('💨', 'Wind', '${_current!.windSpeed.toStringAsFixed(1)} m/s'),
          const SizedBox(width: 12),
          _statCard('🌡️', 'Feels Like', '${_current!.feelsLike.toStringAsFixed(0)}°C'),
        ],
      ),
    );
  }

  Widget _statCard(String emoji, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ─── 7-Day Forecast ───
  Widget _buildForecast() {
    if (_forecast.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${_forecast.length}-DAY FORECAST',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._forecast.asMap().entries.map((entry) {
              final i = entry.key;
              final day = entry.value;
              final isLast = i == _forecast.length - 1;
              return Column(
                children: [
                  _forecastRow(day),
                  if (!isLast)
                    Divider(
                        color: Colors.white.withOpacity(0.1), height: 16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _forecastRow(DayForecast day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Day name
          SizedBox(
            width: 80,
            child: Text(
              _dayName(day.date),
              style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
          // Emoji
          Text(_weatherEmoji(day.description),
              style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          // Rain chance
          if (day.rainChance > 0) ...[
            Text('💧',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.lightBlueAccent.withOpacity(0.8))),
            Text('${day.rainChance}%',
                style: TextStyle(
                    color: Colors.lightBlueAccent.withOpacity(0.8),
                    fontSize: 11)),
          ],
          const Spacer(),
          // Min temp
          Text('${day.tempMin.toStringAsFixed(0)}°',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 14)),
          const SizedBox(width: 8),
          // Temp bar
          _tempBar(day.tempMin, day.tempMax),
          const SizedBox(width: 8),
          // Max temp
          SizedBox(
            width: 36,
            child: Text('${day.tempMax.toStringAsFixed(0)}°',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _tempBar(double min, double max) {
    return Container(
      width: 70,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [
            Colors.lightBlueAccent.withOpacity(0.6),
            Colors.orangeAccent.withOpacity(0.8),
          ],
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}