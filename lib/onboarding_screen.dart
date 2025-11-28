

import 'package:flutter/material.dart';
import 'auth_screen.dart'; // import the auth screen

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final Color logoGreen = const Color.fromARGB(255, 208, 218, 195); // green background

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
            image: "assets/splash2.png",
            title: "Welcome to Yucca Agro App",
            desc: "Cultivating a Sustainable World.",
          ),
          buildPage(
            image: "assets/foods.png",
            title: "Your Farming Partner",
            desc: "Access services, crop info, and expert support.",
           
          ),
          buildPage(
            image: "assets/yucca.png",
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
    bool useBackgroundImage = false, // new parameter
  }) {
    return Container(
      // Use image or color background
      decoration: useBackgroundImage
          ? BoxDecoration(
              image: DecorationImage(
                image: AssetImage(image), // background image
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3), // transparency overlay
                  BlendMode.darken,
                ),
              ),
            )
          : BoxDecoration(
              color: logoGreen,
            ),
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Only show image if not used as background
                if (!useBackgroundImage) Image.asset(image, height: 180),
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
                      MaterialPageRoute(builder: (context) => AuthScreen()),
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
