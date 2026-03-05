import 'package:flutter/material.dart';
import 'tips_detail_screen.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  static const Color green = Color(0xFF366000);
  static const Color cream = Color(0xFFFFEDC7);
  static const Color gold = Color(0xFFC0B87A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: const Text("Farming Tips"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          children: [
            _imageCard(
              context,
              title: "Cattle",
              image: "assets/cattle.jpg",
            ),
            _imageCard(
              context,
              title: "Goats",
              image: "assets/goats.jpg",
            ),
            _imageCard(
              context,
              title: "Poultry",
              image: "assets/poultry.jpg",
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageCard(BuildContext context,
      {required String title, required String image}) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TipsDetailScreen(
              title: title,
              image: image,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: gold),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
