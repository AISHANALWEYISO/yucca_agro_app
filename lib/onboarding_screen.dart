

import 'package:flutter/material.dart';
import 'auth_screen.dart'; // import the auth screen

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final Color logoGreen = const Color.fromARGB(255, 176, 189, 160); // green background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() => currentIndex = index);
        },
        children: [
          buildPage(
            image: "assets/splash.jpeg",
            title: "Welcome to Yucca Agro App",
            desc: "Digitizing agricultural support and post-harvest services.",
          ),
          buildPage(
            image: "assets/logo.png",
            title: "Your Farming Partner",
            desc: "Access services, market info, and expert support.",
          ),
          buildPage(
            image: "assets/logo.png",
            title: "Get Started",
            desc: "Click below to continue to the app.",
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String desc,
    bool isLast = false,
  }) {
    return Container(
      color: logoGreen,
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(image, height: 180),
                const SizedBox(height: 30),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  desc,
                  style: const TextStyle(
                      fontSize: 16, color: Color.fromARGB(179, 29, 107, 36)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Buttons stacked vertically at the bottom center
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button
              currentIndex == 0
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: () {
                        _controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text(
                        "Back",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
              const SizedBox(height: 10),

              // Next / Continue button
              ElevatedButton(
                onPressed: () {
                  if (isLast) {
                    // Navigate to AuthScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AuthScreen()),
                    );
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 28, 128, 66)
                      .withOpacity(0.2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isLast ? "Continue" : "Next",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}
