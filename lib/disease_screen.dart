import 'package:flutter/material.dart';
import 'disease_detail_screen.dart';

class DiseaseListScreen extends StatelessWidget {
  const DiseaseListScreen({super.key});

  static const Color green = Color(0xFF366000);

  final List<Map<String, String>> diseases = const [
    {
      "name": "Foot and Mouth Disease",
      "image": "assets/fmd.jpg",
    },
    {
      "name": "Newcastle Disease",
      "image": "assets/newcastle.jpg",
    },
    {
      "name": "Anthrax",
      "image": "assets/anthrax.jpg",
    },
    {
      "name": "Brucellosis",
      "image": "assets/brucellosis.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Animal Diseases"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: green,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: diseases.length,
        itemBuilder: (context, index) {
          final disease = diseases[index];
          return _diseaseTile(context, disease);
        },
      ),
    );
  }

  Widget _diseaseTile(BuildContext context, Map<String, String> disease) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          disease['name']!,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiseaseDetailScreen(
                title: disease['name']!,
                image: disease['image']!,
              ),
            ),
          );
        },
      ),
    );
  }
}
