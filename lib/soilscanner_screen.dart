// import 'dart:io';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

// // Import your main ApiService for credit checking
// import 'services/api_service.dart';
// import 'payment_screen.dart'; // Adjust path if needed

// // ─────────────────────────────────────────
// //  MODELS
// // ─────────────────────────────────────────
// class SoilAnalysis {
//   final int healthScore;
//   final String soilType;
//   final String texture;
//   final String colorAnalysis;
//   final Map<String, String> estimatedNutrients;
//   final List<CropRecommendation> recommendedCrops;
//   final List<Fertilizer> fertilizers;
//   final List<String> improvementTips;
//   final String summary;

//   SoilAnalysis.fromJson(Map<String, dynamic> j)
//       : healthScore = j['soil_health_score'],
//         soilType = j['soil_type'],
//         texture = j['texture'],
//         colorAnalysis = j['color_analysis'],
//         estimatedNutrients =
//             Map<String, String>.from(j['estimated_nutrients']),
//         recommendedCrops = (j['recommended_crops'] as List)
//             .map((e) => CropRecommendation.fromJson(e))
//             .toList(),
//         fertilizers = (j['fertilizers'] as List)
//             .map((e) => Fertilizer.fromJson(e))
//             .toList(),
//         improvementTips = List<String>.from(j['improvement_tips']),
//         summary = j['summary'];
// }

// class CropRecommendation {
//   final String name;
//   final String suitability;
//   final String reason;
//   CropRecommendation.fromJson(Map<String, dynamic> j)
//       : name = j['name'],
//         suitability = j['suitability'],
//         reason = j['reason'];
// }

// class Fertilizer {
//   final String name;
//   final String type;
//   final String application;
//   Fertilizer.fromJson(Map<String, dynamic> j)
//       : name = j['name'],
//         type = j['type'],
//         application = j['application'];
// }

// // ─────────────────────────────────────────
// //  API SERVICE
// // ─────────────────────────────────────────
// class SoilApiService {
//   static String get baseUrl {
//     if (kIsWeb) return 'http://127.0.0.1:5001/api';
//     if (Platform.isAndroid) return 'http://10.0.2.2:5001/api';
//     return 'http://127.0.0.1:5001/api';
//   }

//   /// Full analysis — sends image + region + season to backend
//   static Future<SoilAnalysis> analyzeSoil({
//     required XFile imageFile,
//     required String region,
//     required String season,
//   }) async {
//     final uri = Uri.parse('$baseUrl/soil/analyze');
//     final request = http.MultipartRequest('POST', uri);

//     // image
//     final bytes = await imageFile.readAsBytes();
//     request.files.add(http.MultipartFile.fromBytes(
//       'image',
//       bytes,
//       filename: imageFile.name,
//     ));

//     // localisation fields
//     request.fields['region'] = region;
//     request.fields['season'] = season;

//     final streamed =
//         await request.send().timeout(const Duration(seconds: 60));
//     final response = await http.Response.fromStream(streamed);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return SoilAnalysis.fromJson(data['analysis']);
//     } else {
//       final err = jsonDecode(response.body);
//       throw Exception(err['error'] ?? 'Failed to analyze soil');
//     }
//   }
// }

// // ─────────────────────────────────────────
// //  MAIN SCREEN
// // ─────────────────────────────────────────
// class SoilScannerScreen extends StatefulWidget {
//   const SoilScannerScreen({super.key});

//   @override
//   State<SoilScannerScreen> createState() => _SoilScannerScreenState();
// }

// class _SoilScannerScreenState extends State<SoilScannerScreen> {
//   // colours
//   static const Color deepGreen = Color(0xFF2D5016);
//   static const Color lightGreen = Color(0xFF8BC34A);
//   static const Color cream = Color(0xFFF5F0E8);

//   XFile? _selectedImage;
//   Uint8List? _imageBytes;
//   SoilAnalysis? _analysis;
//   bool _isLoading = false;
//   String? _error;
//   int _credits = 0; // ✅ Track user credits
//   bool _checkingCredits = false;

//   // localisation
//   String _selectedRegion = 'Central';
//   String _selectedSeason = 'Rainy';

//   final List<String> _regions = ['Central', 'Eastern', 'Northern', 'Western'];
//   final List<String> _seasons = ['Rainy', 'Dry'];

//   final ImagePicker _picker = ImagePicker();
//   final ApiService _api = ApiService(); // ✅ For credit checking

//   @override
//   void initState() {
//     super.initState();
//     _loadCredits(); // ✅ Load credits when screen opens
//   }

//   // ✅ Load user's current credits
//   Future<void> _loadCredits() async {
//     setState(() => _checkingCredits = true);
//     final result = await _api.checkSoilScannerCredits();
//     if (mounted) {
//       setState(() {
//         _credits = result['credits_remaining'] ?? 0;
//         _checkingCredits = false;
//       });
//     }
//   }

//   // ✅ Check credits BEFORE analyzing soil
//   Future<void> _checkCreditsAndAnalyze() async {
//     // First, refresh credits to ensure we have latest
//     await _loadCredits();
    
//     if (_credits <= 0) {
//       _showNoCreditsDialog();
//       return;
//     }
    
//     // Has credits - proceed with analysis
//     _analyzeSoil();
//   }

//   // ✅ Show dialog when user has no credits
//   void _showNoCreditsDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('No Credits Remaining'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('You have $_credits soil scan credit(s) remaining.'),
//             const SizedBox(height: 12),
//             const Text('Each soil analysis requires 1 credit.'),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: deepGreen.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: deepGreen),
//               ),
//               child: const Text(
//                 '💡 Tip: Buy credits in bundles to save money!',
//                 style: TextStyle(fontSize: 12),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(color: deepGreen)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               // Navigate to payment screen
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const PaymentScreen()),
//               ).then((_) => _loadCredits()); // Refresh credits when returning
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: deepGreen,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Buy Credits'),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Pick image ──────────────────────────
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final picked = await _picker.pickImage(
//         source: source,
//         imageQuality: 85,
//         maxWidth: 1200,
//       );
//       if (picked == null) return;
//       final bytes = await picked.readAsBytes();
//       setState(() {
//         _selectedImage = picked;
//         _imageBytes = bytes;
//         _analysis = null;
//         _error = null;
//       });
//     } catch (e) {
//       setState(() => _error = 'Could not pick image: $e');
//     }
//   }

//   // ── Analyse (called after credit check) ─────────────────────────────
//   Future<void> _analyzeSoil() async {
//     if (_selectedImage == null) return;
    
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
    
//     try {
//       final result = await SoilApiService.analyzeSoil(
//         imageFile: _selectedImage!,
//         region: _selectedRegion,
//         season: _selectedSeason,
//       );
      
//       setState(() {
//         _analysis = result;
//         _credits -= 1; // ✅ Deduct 1 credit after successful analysis
//       });
      
//       // Optional: Show success message with remaining credits
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Analysis complete! $_credits credit(s) remaining.'),
//             backgroundColor: deepGreen,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
      
//     } catch (e) {
//       setState(
//           () => _error = e.toString().replaceFirst('Exception: ', ''));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // ─────────────────────────────────────────
//   //  BUILD
//   // ─────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: cream,
//       appBar: AppBar(
//         backgroundColor: deepGreen,
//         foregroundColor: Colors.white,
//         title: const Text(
//           'Soil Scanner',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         actions: [
//           // ✅ Show credits in app bar
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: Row(
//               children: [
//                 Icon(Icons.eco, color: Colors.white, size: 18),
//                 const SizedBox(width: 4),
//                 Text(
//                   '$_credits',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // photo picker
//             _buildImagePicker(),
//             const SizedBox(height: 16),

//             // region + season selectors — always visible
//             _buildLocationSelectors(),
//             const SizedBox(height: 16),

//             // ✅ Show credits status
//             _buildCreditsStatus(),
//             const SizedBox(height: 16),

//             if (_error != null) _buildError(),

//             if (_selectedImage != null && _analysis == null && !_isLoading)
//               _buildAnalyzeButton(),

//             if (_isLoading) _buildLoading(),

//             if (_analysis != null) _buildResults(),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ Show current credits status
//   Widget _buildCreditsStatus() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: _credits > 0 ? Colors.green[50] : Colors.orange[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: _credits > 0 ? Colors.green : Colors.orange,
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             _credits > 0 ? Icons.check_circle : Icons.warning_amber,
//             color: _credits > 0 ? Colors.green : Colors.orange,
//             size: 20,
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               _credits > 0
//                   ? 'You have $_credits soil scan credit(s) available'
//                   : 'No credits remaining - buy credits to continue',
//               style: TextStyle(
//                 fontSize: 13,
//                 color: _credits > 0 ? Colors.green[800] : Colors.orange[800],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           if (_credits == 0)
//             TextButton(
//               onPressed: _showNoCreditsDialog,
//               child: const Text('Buy Now', style: TextStyle(fontSize: 12)),
//             ),
//         ],
//       ),
//     );
//   }

//   // ── Region + Season row ─────────────────
//   Widget _buildLocationSelectors() {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildDropdown(
//             label: 'Region',
//             value: _selectedRegion,
//             items: _regions,
//             onChanged: (v) => setState(() => _selectedRegion = v!),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _buildDropdown(
//             label: 'Season',
//             value: _selectedSeason,
//             items: _seasons,
//             onChanged: (v) => setState(() => _selectedSeason = v!),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdown({
//     required String label,
//     required String value,
//     required List<String> items,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w700,
//             color: deepGreen,
//           ),
//         ),
//         const SizedBox(height: 6),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: lightGreen.withOpacity(0.5)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.04),
//                 blurRadius: 6,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: value,
//               isExpanded: true,
//               style: const TextStyle(
//                 fontSize: 13,
//                 color: Color(0xFF1A2B1C),
//                 fontWeight: FontWeight.w600,
//               ),
//               items: items
//                   .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                   .toList(),
//               onChanged: onChanged,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ── Image Picker Card ───────────────────
//   Widget _buildImagePicker() {
//     return Container(
//       height: 240,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: lightGreen, width: 2),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: _imageBytes != null
//           ? Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(18),
//                   child: Image.memory(
//                     _imageBytes!,
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: double.infinity,
//                   ),
//                 ),
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: GestureDetector(
//                     onTap: () => setState(() {
//                       _selectedImage = null;
//                       _imageBytes = null;
//                       _analysis = null;
//                     }),
//                     child: Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: const BoxDecoration(
//                         color: Colors.black54,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(Icons.close,
//                           color: Colors.white, size: 18),
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           : Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.landscape, size: 64, color: lightGreen),
//                 const SizedBox(height: 12),
//                 const Text(
//                   'Take or upload a photo of your soil',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Color(0xFF555555),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     if (!kIsWeb)
//                       _sourceButton('Camera',
//                           () => _pickImage(ImageSource.camera)),
//                     if (!kIsWeb) const SizedBox(width: 16),
//                     _sourceButton('Gallery',
//                         () => _pickImage(ImageSource.gallery)),
//                   ],
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _sourceButton(String label, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         decoration: BoxDecoration(
//           color: deepGreen,
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 13,
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Analyse button ──────────────────────
//   Widget _buildAnalyzeButton() {
//     return ElevatedButton(
//       // ✅ Call credit check before analyzing
//       onPressed: _checkingCredits ? null : _checkCreditsAndAnalyze,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: deepGreen,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14)),
//         elevation: 4,
//       ),
//       child: _checkingCredits
//           ? const SizedBox(
//               height: 20,
//               width: 20,
//               child: CircularProgressIndicator(
//                 color: Colors.white,
//                 strokeWidth: 2,
//               ),
//             )
//           : const Text(
//               'Analyse Soil (1 Credit)',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//     );
//   }

//   // ── Loading ─────────────────────────────
//   Widget _buildLoading() {
//     return Container(
//       padding: const EdgeInsets.all(32),
//       child: Column(
//         children: [
//           const CircularProgressIndicator(
//               color: deepGreen, strokeWidth: 3),
//           const SizedBox(height: 16),
//           Text('Analysing your soil...',
//               style: TextStyle(color: Colors.grey[600], fontSize: 15)),
//           const SizedBox(height: 4),
//           Text('This may take a moment',
//               style: TextStyle(color: Colors.grey[400], fontSize: 13)),
//         ],
//       ),
//     );
//   }

//   // ── Error ───────────────────────────────
//   Widget _buildError() {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFEBEE),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.red.shade200),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.error_outline, color: Colors.red),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(_error!,
//                 style: const TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────
//   //  RESULTS
//   // ─────────────────────────────────────────
//   Widget _buildResults() {
//     final a = _analysis!;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         const SizedBox(height: 8),
//         _buildHealthScore(a.healthScore),
//         const SizedBox(height: 16),
//         _buildSoilInfo(a),
//         const SizedBox(height: 16),
//         _buildNutrients(a.estimatedNutrients),
//         const SizedBox(height: 16),
//         _buildCrops(a.recommendedCrops),
//         const SizedBox(height: 16),
//         _buildFertilizers(a.fertilizers),
//         const SizedBox(height: 16),
//         _buildTips(a.improvementTips),
//         const SizedBox(height: 16),
//         _buildSummary(a.summary),
//         const SizedBox(height: 24),
//         OutlinedButton(
//           onPressed: () => setState(() {
//             _selectedImage = null;
//             _imageBytes = null;
//             _analysis = null;
//             _loadCredits(); // ✅ Refresh credits when starting new scan
//           }),
//           style: OutlinedButton.styleFrom(
//             foregroundColor: deepGreen,
//             side: const BorderSide(color: deepGreen),
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14)),
//           ),
//           child: const Text('Scan Another Sample',
//               style: TextStyle(fontWeight: FontWeight.w600)),
//         ),
//       ],
//     );
//   }

//   Widget _buildHealthScore(int score) {
//     final color = score >= 70
//         ? const Color(0xFF4CAF50)
//         : score >= 40
//             ? const Color(0xFFFF9800)
//             : const Color(0xFFF44336);
//     final label =
//         score >= 70 ? 'Healthy' : score >= 40 ? 'Moderate' : 'Poor';

//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF2D5016), Color(0xFF4CAF50)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: deepGreen.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               SizedBox(
//                 width: 80,
//                 height: 80,
//                 child: CircularProgressIndicator(
//                   value: score / 100,
//                   strokeWidth: 7,
//                   backgroundColor: Colors.white24,
//                   valueColor: AlwaysStoppedAnimation<Color>(color),
//                 ),
//               ),
//               Text('$score',
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold)),
//             ],
//           ),
//           const SizedBox(width: 20),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Soil Health Score',
//                     style:
//                         TextStyle(color: Colors.white70, fontSize: 13)),
//                 const SizedBox(height: 4),
//                 Text(label,
//                     style: TextStyle(
//                         color: color,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 4),
//                 const Text('out of 100',
//                     style:
//                         TextStyle(color: Colors.white54, fontSize: 12)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSoilInfo(SoilAnalysis a) {
//     return _card(
//       title: 'Soil Profile',
//       child: Column(
//         children: [
//           _infoRow('Type', a.soilType),
//           _infoRow('Texture', a.texture),
//           _infoRow('Colour Analysis', a.colorAnalysis),
//           // show selected region + season
//           _infoRow('Region', _selectedRegion),
//           _infoRow('Season', '$_selectedSeason Season'),
//         ],
//       ),
//     );
//   }

//   Widget _buildNutrients(Map<String, String> nutrients) {
//     return _card(
//       title: 'Estimated Nutrients',
//       child: Wrap(
//         spacing: 10,
//         runSpacing: 10,
//         children: nutrients.entries.map((e) {
//           final levelColor = e.value == 'High'
//               ? const Color(0xFF4CAF50)
//               : e.value == 'Medium' || e.value == 'Neutral'
//                   ? const Color(0xFFFF9800)
//                   : const Color(0xFFF44336);
//           return Container(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 14, vertical: 10),
//             decoration: BoxDecoration(
//               color: levelColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//               border:
//                   Border.all(color: levelColor.withOpacity(0.3)),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   e.key
//                       .replaceAll('_', ' ')
//                       .toUpperCase(),
//                   style: const TextStyle(
//                       fontSize: 10,
//                       color: Colors.grey,
//                       fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   e.value,
//                   style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                       color: levelColor),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildCrops(List<CropRecommendation> crops) {
//     return _card(
//       title: 'Recommended Crops — $_selectedRegion · $_selectedSeason Season',
//       child: Column(
//         children: crops.map((c) {
//           final color = c.suitability == 'Excellent'
//               ? const Color(0xFF4CAF50)
//               : c.suitability == 'Good'
//                   ? const Color(0xFF8BC34A)
//                   : const Color(0xFFFF9800);
//           return Container(
//             margin: const EdgeInsets.only(bottom: 10),
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: color.withOpacity(0.3)),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: color,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     c.suitability,
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(c.name,
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 15)),
//                       const SizedBox(height: 2),
//                       Text(c.reason,
//                           style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 12)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildFertilizers(List<Fertilizer> fertilizers) {
//     return _card(
//       title: 'Recommended Fertilizers',
//       child: Column(
//         children: fertilizers
//             .map((f) => Container(
//                   margin: const EdgeInsets.only(bottom: 10),
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFF8E1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                         color: const Color(0xFFFFE082)),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(f.name,
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 15)),
//                           const Spacer(),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 3),
//                             decoration: BoxDecoration(
//                               color: f.type == 'Organic'
//                                   ? const Color(0xFF4CAF50)
//                                   : const Color(0xFF2196F3),
//                               borderRadius:
//                                   BorderRadius.circular(6),
//                             ),
//                             child: Text(f.type,
//                                 style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 11)),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       Text(f.application,
//                           style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 13)),
//                     ],
//                   ),
//                 ))
//             .toList(),
//       ),
//     );
//   }

//   Widget _buildTips(List<String> tips) {
//     return _card(
//       title: 'Improvement Tips',
//       child: Column(
//         children: tips
//             .asMap()
//             .entries
//             .map((e) => Padding(
//                   padding: const EdgeInsets.only(bottom: 8),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: 24,
//                         height: 24,
//                         alignment: Alignment.center,
//                         decoration: const BoxDecoration(
//                           color: deepGreen,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Text(
//                           '${e.key + 1}',
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(e.value,
//                             style: const TextStyle(
//                                 fontSize: 14, height: 1.5)),
//                       ),
//                     ],
//                   ),
//                 ))
//             .toList(),
//       ),
//     );
//   }

//   Widget _buildSummary(String summary) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE8F5E9),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFFA5D6A7)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Summary',
//             style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 15,
//                 color: deepGreen),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             summary,
//             style: const TextStyle(
//                 fontSize: 14, height: 1.6, color: Color(0xFF333333)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Shared card widget ──────────────────
//   Widget _card({required String title, required Widget child}) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 15,
//                 color: deepGreen),
//           ),
//           const SizedBox(height: 12),
//           child,
//         ],
//       ),
//     );
//   }

//   Widget _infoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(label,
//                 style: TextStyle(
//                     color: Colors.grey[600], fontSize: 13)),
//           ),
//           Expanded(
//             child: Text(value,
//                 style: const TextStyle(
//                     fontWeight: FontWeight.w600, fontSize: 13)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// soil_scanner_screen.dart


// soil_scanner_screen.dart
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'services/api_service.dart';
import 'payment_screen.dart';

// ─────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────
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
  final String name, suitability, reason;
  CropRecommendation.fromJson(Map<String, dynamic> j)
      : name = j['name'],
        suitability = j['suitability'],
        reason = j['reason'];
}

class Fertilizer {
  final String name, type, application;
  Fertilizer.fromJson(Map<String, dynamic> j)
      : name = j['name'],
        type = j['type'],
        application = j['application'];
}

// ─────────────────────────────────────────
//  API SERVICE
// ─────────────────────────────────────────
class SoilApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:5001/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5001/api';
    return 'http://127.0.0.1:5001/api';
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<SoilAnalysis> analyzeSoil({
    required XFile imageFile,
    required String region,
    required String season,
  }) async {
    final uri = Uri.parse('$baseUrl/soil/analyze');
    final request = http.MultipartRequest('POST', uri);

    // Attach JWT auth header
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
      print('🔑 Auth header attached: Bearer ${token.substring(0, 20)}...');
    } else {
      print('⚠️ No auth token found');
    }

    // Attach image
    final bytes = await imageFile.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name),
    );

    // Attach form fields
    request.fields['region'] = region;
    request.fields['season'] = season;

    print('📤 Sending request to: $uri');
    print('📦 Form fields: region=$region, season=$season');

    // Send request
    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);

    print('📥 Response status: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('❌ Error body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Analysis successful');
      return SoilAnalysis.fromJson(data['analysis']);
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? err['message'] ?? 'Failed to analyze soil');
    }
  }

  // ✅ MOCK DATA FOR TESTING (remove in production)
  static SoilAnalysis getMockAnalysis(String region, String season) {
    return SoilAnalysis(
      healthScore: 78,
      soilType: 'Loam',
      texture: 'Medium',
      colorAnalysis: 'Brown',
      estimatedNutrients: {
        'nitrogen': 'Medium',
        'phosphorus': 'High',
        'potassium': 'Low',
        'ph_level': 'optimal',
      },
      recommendedCrops: [
        CropRecommendation(
          name: 'maize',
          suitability: 'Excellent',
          reason: 'Matches soil pH and nutrient profile for $region $season season',
        ),
        CropRecommendation(
          name: 'soybean',
          suitability: 'Good',
          reason: 'Tolerates current soil conditions well',
        ),
        CropRecommendation(
          name: 'cotton',
          suitability: 'Moderate',
          reason: 'Requires additional potassium for optimal yield',
        ),
      ],
      fertilizers: [
        Fertilizer(
          name: 'Urea (46-0-0)',
          type: 'Chemical',
          application: 'Apply 50 kg/ha at planting to boost nitrogen',
        ),
        Fertilizer(
          name: 'Well-rotted compost',
          type: 'Organic',
          application: 'Mix 5-10 tons/ha before planting to improve structure',
        ),
      ],
      improvementTips: [
        'Add organic matter to improve soil structure and water retention',
        'Monitor potassium levels for fruiting crops',
        'Rotate crops annually to maintain soil fertility',
        'Ensure proper drainage to prevent waterlogging during $season season',
      ],
      summary:
          'Soil in $region ($season season) shows good health. Maize is the top recommendation. Add potassium-rich fertilizer for best yields.',
    );
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
  static const Color deepGreen = Color(0xFF2D5016);
  static const Color lightGreen = Color(0xFF8BC34A);
  static const Color cream = Color(0xFFF5F0E8);

  XFile? _selectedImage;
  Uint8List? _imageBytes;
  SoilAnalysis? _analysis;
  bool _isLoading = false;
  String? _error;
  int _credits = 99; // ✅ DEBUG: Start with plenty of credits for testing
  bool _checkingCredits = false;

  // ✅ DEBUG FLAG: Set to true to bypass credit check & use mock data
  static const bool _debugBypass = true;

  String _selectedRegion = 'Central';
  String _selectedSeason = 'Rainy';

  final List<String> _regions = ['Central', 'Eastern', 'Northern', 'Western'];
  final List<String> _seasons = ['Rainy', 'Dry'];

  final ImagePicker _picker = ImagePicker();
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    if (!_debugBypass) {
      _loadCredits();
    }
  }

  @override
  void dispose() {
    _selectedImage = null;
    _imageBytes = null;
    super.dispose();
  }

  Future<void> _loadCredits() async {
    if (_debugBypass) return;
    
    setState(() => _checkingCredits = true);
    try {
      final result = await _api.checkSoilScannerCredits();
      if (mounted) {
        setState(() {
          _credits = result['credits_remaining'] ?? 0;
          _checkingCredits = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load credits: $e';
          _checkingCredits = false;
        });
      }
    }
  }

  Future<void> _checkCreditsAndAnalyze() async {
    if (_debugBypass) {
      _analyzeSoil();
      return;
    }
    
    await _loadCredits();
    if (_credits <= 0) {
      _showNoCreditsDialog();
      return;
    }
    _analyzeSoil();
  }

  void _showNoCreditsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Credits Remaining'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have $_credits soil scan credit(s) remaining.'),
            const SizedBox(height: 12),
            const Text('Each soil analysis requires 1 credit.'),
          ],
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: deepGreen)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentScreen()),
              ).then((_) => _loadCredits());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: deepGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Buy Credits'),
          ),
        ],
      ),
    );
  }

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
      print('🔍 Starting soil analysis...');
      print('📷 Image: ${_selectedImage!.name}');
      print('🌍 Region: $_selectedRegion, Season: $_selectedSeason');
      
      SoilAnalysis result;
      
      if (_debugBypass) {
        // ✅ Use mock data for instant testing
        print('🧪 Using mock data (debug mode)');
        await Future.delayed(const Duration(seconds: 2)); // Simulate API delay
        result = SoilApiService.getMockAnalysis(_selectedRegion, _selectedSeason);
      } else {
        // ✅ Call real backend
        print('🌐 Calling real backend API');
        result = await SoilApiService.analyzeSoil(
          imageFile: _selectedImage!,
          region: _selectedRegion,
          season: _selectedSeason,
        );
      }
      
      setState(() {
        _analysis = result;
        if (!_debugBypass) {
          _credits -= 1;
        }
      });
      
      print('✅ Analysis complete!');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis complete! ${_debugBypass ? 'Demo' : _credits} credit(s) remaining.'),
            backgroundColor: deepGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Analysis error: $e');
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Soil Scanner',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // ✅ Debug indicator
          if (_debugBypass)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'DEBUG',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.eco, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_credits',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 16),
            _buildLocationSelectors(),
            const SizedBox(height: 16),
            _buildCreditsStatus(),
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

  Widget _buildCreditsStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _credits > 0 ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _credits > 0 ? Colors.green : Colors.orange),
      ),
      child: Row(
        children: [
          Icon(
            _credits > 0 ? Icons.check_circle : Icons.warning_amber,
            color: _credits > 0 ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _debugBypass
                  ? '🧪 Debug Mode: Unlimited scans'
                  : _credits > 0
                      ? 'You have $_credits soil scan credit(s) available'
                      : 'No credits remaining - buy credits to continue',
              style: TextStyle(
                fontSize: 13,
                color: _credits > 0 ? Colors.green[800] : Colors.orange[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!_debugBypass && _credits == 0)
            TextButton(
              onPressed: _showNoCreditsDialog,
              child: const Text('Buy Now', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationSelectors() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            label: 'Region',
            value: _selectedRegion,
            items: _regions,
            onChanged: (v) => setState(() => _selectedRegion = v!),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdown(
            label: 'Season',
            value: _selectedSeason,
            items: _seasons,
            onChanged: (v) => setState(() => _selectedSeason = v!),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: deepGreen,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: lightGreen.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1A2B1C),
                fontWeight: FontWeight.w600,
              ),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lightGreen, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
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
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.landscape, size: 64, color: lightGreen),
                const SizedBox(height: 12),
                const Text(
                  'Take or upload a photo of your soil',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF555555),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!kIsWeb)
                      _sourceButton('Camera', () => _pickImage(ImageSource.camera)),
                    if (!kIsWeb) const SizedBox(width: 16),
                    _sourceButton('Gallery', () => _pickImage(ImageSource.gallery)),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _sourceButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: deepGreen,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return ElevatedButton(
      onPressed: _checkingCredits || _debugBypass ? null : _checkCreditsAndAnalyze,
      style: ElevatedButton.styleFrom(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
      ),
      child: _checkingCredits
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Text(
              _debugBypass ? '🧪 Test Analysis (Mock)' : 'Analyse Soil (1 Credit)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const CircularProgressIndicator(color: deepGreen, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            _debugBypass ? 'Generating demo analysis...' : 'Analysing your soil...',
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'This may take a moment',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
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
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
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
        OutlinedButton(
          onPressed: () => setState(() {
            _selectedImage = null;
            _imageBytes = null;
            _analysis = null;
            if (!_debugBypass) _loadCredits();
          }),
          style: OutlinedButton.styleFrom(
            foregroundColor: deepGreen,
            side: const BorderSide(color: deepGreen),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text(
            'Scan Another Sample',
            style: TextStyle(fontWeight: FontWeight.w600),
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
    final label = score >= 70 ? 'Healthy' : score >= 40 ? 'Moderate' : 'Poor';

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
            color: deepGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
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
              Text(
                '$score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Soil Health Score',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'out of 100',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilInfo(SoilAnalysis a) {
    return _card(
      title: 'Soil Profile',
      child: Column(
        children: [
          _infoRow('Type', a.soilType),
          _infoRow('Texture', a.texture),
          _infoRow('Colour Analysis', a.colorAnalysis),
          _infoRow('Region', _selectedRegion),
          _infoRow('Season', '$_selectedSeason Season'),
        ],
      ),
    );
  }

  Widget _buildNutrients(Map<String, String> nutrients) {
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
                Text(
                  e.key.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: levelColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCrops(List<CropRecommendation> crops) {
    return _card(
      title: 'Recommended Crops — $_selectedRegion · $_selectedSeason Season',
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    c.suitability,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.reason,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
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
      title: 'Recommended Fertilizers',
      child: Column(
        children: fertilizers.map((f) => Container(
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
                  Text(
                    f.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: f.type == 'Organic'
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      f.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                f.application,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildTips(List<String> tips) {
    return _card(
      title: 'Improvement Tips',
      child: Column(
        children: tips.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: deepGreen,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${e.key + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  e.value,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        )).toList(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: deepGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF333333)),
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: deepGreen,
            ),
          ),
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
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}