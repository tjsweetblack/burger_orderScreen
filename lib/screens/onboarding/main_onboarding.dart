// onboarding_screen.dart (Create a new file named this, or place it in a relevant folder)
import 'package:auth_bloc/screens/onboarding/screens/onboarding_screens.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth_bloc/routing/routes.dart';

class mainOnboarding extends StatefulWidget {
  const mainOnboarding({super.key});

  @override
  State<mainOnboarding> createState() => _mainOnboardingState();
}

class _mainOnboardingState extends State<mainOnboarding> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  void _navigateToMainApp() {
    _setOnboardingComplete();
    Navigator.of(context)
        .pushReplacementNamed(Routes.loginScreen); // Navigate to main app
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 255, 252, 252), // Set background color to black
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        actions: [
          if (_currentPage < 2) // Show "Skip" only on first two pages
            TextButton(
              onPressed: _navigateToMainApp,
              child: const Text('Skip',
                  style: TextStyle(
                      color:
                          Color.fromARGB(255, 58, 56, 56))), // White Skip text
            ),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: const <Widget>[
              OnboardingPage1(),
              OnboardingPage2(),
              OnboardingPage3(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
                bottom: 90.0), // Increased bottom padding to accommodate button
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              // Wrap buttons in a Column
              children: [
                if (_currentPage < 2) // Show "Next" button on pages 1 and 2
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40.0,
                            vertical:
                                16.0), // Increased horizontal and vertical padding
                        minimumSize: const Size(double.infinity,
                            48.0), // Make button wider and set a minimum height
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text("next",
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255))),
                    ),
                  ),
                if (_currentPage ==
                    2) // Show "Get Started" button only on the last page
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: ElevatedButton(
                      onPressed: _navigateToMainApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40.0,
                            vertical:
                                16.0), // Increased horizontal and vertical padding
                        minimumSize: const Size(double.infinity,
                            48.0), // Make button wider and set a minimum height
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text("Começar Agora",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.red
            : Colors.grey[700], // Slightly darker grey for inactive
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < 3; i++) {
      indicators.add(
        _indicator(i == _currentPage),
      );
    }
    return indicators;
  }
}
