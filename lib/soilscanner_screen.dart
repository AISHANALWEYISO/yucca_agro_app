import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

// model

class SoilAnalysis {
  final int healthScore;
  final String soilType;
  final String texture;
  final String colorAnalysis;
  final Map<String, String> estimatedNutrients;
  final List<CropRecommendation> recommendedCrops;
  final List<Fertilizer> fertilizers;
  final List<String> improvementTips;
  final String summary;

  SoilAnalysis.fromJson(Map<String, dynamic> j)
      : healthScore = j['soil_health_score'],
        soilType = j['soil_type'],
        texture = j['texture'],
        colorAnalysis = j['color_analysis'],
        estimatedNutrients = Map<String, String>.from(j['estimated_nutrients']),
        recommendedCrops = (j['recommended_crops'] as List)
            .map((e) => CropRecommendation.fromJson(e))
            .toList(),
        fertilizers = (j['fertilizers'] as List)
            .map((e) => Fertilizer.fromJson(e))
            .toList(),
        improvementTips = List<String>.from(j['improvement_tips']),
        summary = j['summary'];
}

class CropRecommendation {
  final String name;
  final String suitability;
  final String reason;
  CropRecommendation.fromJson(Map<String, dynamic> j)
      : name = j['name'],
        suitability = j['suitability'],
        reason = j['reason'];
}

class Fertilizer {
  final String name;
  final String type;
  final String application;
  Fertilizer.fromJson(Map<String, dynamic> j)
      : name = j['name'],
        type = j['type'],
        application = j['application'];
}

// API SERVICE

class SoilApiService {
  // For Android emulator use 10.0.2.2, for web/desktop use localhost
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:5001/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5001/api';
    return 'http://127.0.0.1:5001/api';
  }

  static Future<SoilAnalysis> analyzeSoil(XFile imageFile) async {
    final uri = Uri.parse('$baseUrl/soil/analyze');
    final request = http.MultipartRequest('POST', uri);

    final bytes = await imageFile.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: imageFile.name,
    ));

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SoilAnalysis.fromJson(data['analysis']);
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? 'Failed to analyze soil');
    }
  }
}

// ─────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────
class SoilScannerScreen extends StatefulWidget {
  const SoilScannerScreen({super.key});

  @override
  State<SoilScannerScreen> createState() => _SoilScannerScreenState();
}

class _SoilScannerScreenState extends State<SoilScannerScreen> {
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  SoilAnalysis? _analysis;
  bool _isLoading = false;
  String? _error;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImage = picked;
        _imageBytes = bytes;
        _analysis = null;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Could not pick image: $e');
    }
  }

  Future<void> _analyzeSoil() async {
    if (_selectedImage == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await SoilApiService.analyzeSoil(_selectedImage!);
      setState(() => _analysis = result);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D5016),
        foregroundColor: Colors.white,
        title: const Text(
          ' Soil Scanner',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 16),
            if (_error != null) _buildError(),
            if (_selectedImage != null && _analysis == null && !_isLoading)
              _buildAnalyzeButton(),
            if (_isLoading) _buildLoading(),
            if (_analysis != null) _buildResults(),
          ],
        ),
      ),
    );
  }

  // ── Image Picker Card ──
  Widget _buildImagePicker() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8BC34A), width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: _imageBytes != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.memory(
                    _imageBytes!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedImage = null;
                      _imageBytes = null;
                      _analysis = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.landscape,
                    size: 64, color: Color(0xFF8BC34A)),
                const SizedBox(height: 12),
                const Text('Take or upload a photo of your soil',
                    style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF555555),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hide camera button on web
                    if (!kIsWeb)
                      _sourceButton(Icons.camera_alt, 'Camera',
                          () => _pickImage(ImageSource.camera)),
                    if (!kIsWeb) const SizedBox(width: 16),
                    _sourceButton(Icons.photo_library, 'Gallery',
                        () => _pickImage(ImageSource.gallery)),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _sourceButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2D5016),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return ElevatedButton.icon(
      onPressed: _analyzeSoil,
      icon: const Icon(Icons.biotech),
      label: const Text('Analyze Soil',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2D5016),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const CircularProgressIndicator(
              color: Color(0xFF2D5016), strokeWidth: 3),
          const SizedBox(height: 16),
          Text('Analyzing your soil...',
              style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          const SizedBox(height: 4),
          Text('This may take a moment',
              style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Text(_error!, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final a = _analysis!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        _buildHealthScore(a.healthScore),
        const SizedBox(height: 16),
        _buildSoilInfo(a),
        const SizedBox(height: 16),
        _buildNutrients(a.estimatedNutrients),
        const SizedBox(height: 16),
        _buildCrops(a.recommendedCrops),
        const SizedBox(height: 16),
        _buildFertilizers(a.fertilizers),
        const SizedBox(height: 16),
        _buildTips(a.improvementTips),
        const SizedBox(height: 16),
        _buildSummary(a.summary),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _selectedImage = null;
            _imageBytes = null;
            _analysis = null;
          }),
          icon: const Icon(Icons.refresh),
          label: const Text('Scan Another Sample'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2D5016),
            side: const BorderSide(color: Color(0xFF2D5016)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthScore(int score) {
    final color = score >= 70
        ? const Color(0xFF4CAF50)
        : score >= 40
            ? const Color(0xFFFF9800)
            : const Color(0xFFF44336);
    final label =
        score >= 70 ? 'Healthy' : score >= 40 ? 'Moderate' : 'Poor';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D5016), Color(0xFF4CAF50)],
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
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 7,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text('$score',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Soil Health Score',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('out of 100',
                    style:
                        TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilInfo(SoilAnalysis a) {
    return _card(
      title: ' Soil Profile',
      child: Column(
        children: [
          _infoRow('Type', a.soilType),
          _infoRow('Texture', a.texture),
          _infoRow('Color Analysis', a.colorAnalysis),
        ],
      ),
    );
  }

  Widget _buildNutrients(Map<String, String> nutrients) {
    final icons = {
      'nitrogen': '🌿',
      'phosphorus': '🔵',
      'potassium': '🟠',
      'pH_estimate': '⚗️'
    };
    return _card(
      title: 'Estimated Nutrients',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: nutrients.entries.map((e) {
          final levelColor = e.value == 'High'
              ? const Color(0xFF4CAF50)
              : e.value == 'Medium' || e.value == 'Neutral'
                  ? const Color(0xFFFF9800)
                  : const Color(0xFFF44336);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: levelColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(icons[e.key] ?? '📊',
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 4),
                Text(
                    e.key
                        .replaceAll('_', ' ')
                        .toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600)),
                Text(e.value,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: levelColor)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCrops(List<CropRecommendation> crops) {
    return _card(
      title: 'Recommended Crops',
      child: Column(
        children: crops.map((c) {
          final color = c.suitability == 'Excellent'
              ? const Color(0xFF4CAF50)
              : c.suitability == 'Good'
                  ? const Color(0xFF8BC34A)
                  : const Color(0xFFFF9800);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(c.suitability,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(c.reason,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFertilizers(List<Fertilizer> fertilizers) {
    return _card(
      title: ' Recommended Fertilizers',
      child: Column(
        children: fertilizers
            .map((f) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(f.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: f.type == 'Organic'
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF2196F3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(f.type,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(f.application,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTips(List<String> tips) {
    return _card(
      title: 'Improvement Tips',
      child: Column(
        children: tips
            .asMap()
            .entries
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: Color(0xFF2D5016),
                            shape: BoxShape.circle),
                        child: Text('${e.key + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(e.value,
                              style: const TextStyle(
                                  fontSize: 14, height: 1.5))),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSummary(String summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Summary',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF2D5016))),
                const SizedBox(height: 6),
                Text(summary,
                    style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF333333))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2D5016))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style:
                    TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }
}