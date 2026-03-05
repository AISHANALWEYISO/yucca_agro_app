import 'package:flutter/material.dart';

class TipsDetailScreen extends StatelessWidget {
  final String title;
  final String image;

  const TipsDetailScreen({
    super.key,
    required this.title,
    required this.image,
  });

  static const Color green = Color(0xFF366000);
  static const Color cream = Color(0xFFFFEDC7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: green,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              image,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$title Farming Tips",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._getTips(title).map(_tipItem).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<String> _getTips(String type) {
    switch (type) {
      case "Cattle":
        return [
          "Provide clean drinking water at all times.",
          "Vaccinate regularly to prevent diseases.",
          "Ensure balanced feeding and pasture grazing.",
          "Maintain clean and dry shelters.",
          "Control ticks and parasites frequently.",
        ];
      case "Goats":
        return [
          "Provide dry, raised housing.",
          "Feed quality forage and supplements.",
          "Deworm regularly.",
          "Trim hooves to prevent infections.",
          "Provide mineral blocks.",
        ];
      case "Poultry":
        return [
          "Ensure clean water supply daily.",
          "Provide balanced poultry feeds.",
          "Maintain hygiene in poultry houses.",
          "Vaccinate chicks early.",
          "Control mites and parasites.",
        ];
      default:
        return [];
    }
  }

  Widget _tipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
