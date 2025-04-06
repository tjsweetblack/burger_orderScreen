// onboarding_pages.dart
import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final double? imageHeight; // Added imageHeight parameter

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.imageHeight = 200.0, // Default imageHeight is 200.0
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Wrap Padding in Container for background color
      color: const Color.fromARGB(
          255, 255, 255, 255), // Set page background to black
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(imagePath, height: imageHeight), // Use imageHeight here
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0), // White title text
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 255, 255,
                    255)), // Slightly less opaque white for description
          ),
        ],
      ),
    );
  }
}

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPage(
      title: "Juntos contra a malária: previna, alerte, combata!",
      description: "Juntos contra a malária: previna, alerte, combata!",
      imagePath: 'assets/images/on1.png', // Replace with your image asset path
      imageHeight: 400.0, // Example: Keeping default height of 200
    );
  }
}

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPage(
      title:
          "A cada minuto, vidas são afetadas pela malária. Faça a diferença!",
      description:
          "A cada minuto, vidas são afetadas pela malária. Faça a diferença!",
      imagePath: 'assets/images/on2.png', // Replace with your image asset path
      imageHeight: 400.0, // Example: Keeping default height of 200
    );
  }
}

class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPage(
      title: "Malária sob controle: prevenção em ação!",
      description: "Malária sob controle: prevenção em ação!",
      imagePath: 'assets/images/on3.png', // Replace with your image asset path
      imageHeight: 400.0, // Example: Keeping default height of 200
    );
  }
}
