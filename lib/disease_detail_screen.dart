import 'package:flutter/material.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final String title;
  final String image;

  const DiseaseDetailScreen({
    super.key,
    required this.title,
    required this.image,
  });

  static const Color olive = Color(0xFF6B7445);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: olive,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: olive,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Description"),
                    _sectionText(_description(title)),
                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(image, fit: BoxFit.cover),
                    ),

                    const SizedBox(height: 12),
                    _sectionTitle("Signs and symptoms"),
                    _sectionText(_signs(title)),

                    const SizedBox(height: 12),
                    _sectionTitle("Prevention"),
                    _sectionText(_prevention(title)),

                    const SizedBox(height: 12),
                    _sectionTitle("Treatment"),
                    _sectionText(_treatment(title)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, height: 1.4),
    );
  }

  static String _description(String disease) {
    return "This disease affects animals and can cause serious health problems if not treated early.";
  }

  static String _signs(String disease) {
    return "• Fever\n• Loss of appetite\n• Weakness\n• Diarrhea\n• Reduced production";
  }

  static String _prevention(String disease) {
    return "• Vaccination\n• Maintain hygiene\n• Isolate infected animals\n• Regular veterinary checks";
  }

  static String _treatment(String disease) {
    return "• Seek veterinary assistance\n• Proper medication\n• Isolate sick animals\n• Maintain hydration";
  }
}
