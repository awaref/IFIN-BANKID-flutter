import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatelessWidget {
  final String title;
  final String description;
  final PageController pageController;
  final int currentIndex;
  final int totalScreens;
  final String buttonText;

  const OnboardingScreen({
    super.key,
    required this.title,
    required this.description,
    required this.pageController,
    required this.currentIndex,
    required this.totalScreens,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo at the top
              Center(
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  height: 60,
                  width: 60,
                ),
              ),
              const Spacer(),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7F8C8D),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Progress indicator
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Spacer(),
              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (currentIndex == totalScreens - 1) {
                      // This is the last onboarding screen, navigate to home
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const PlaceholderHomeScreen()),
                      );
                    } else {
                      // Navigate to the next onboarding screen
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Your digital identity is secure',
      'description': 'Easily verify your personal identity and get comprehensive protection for all your data.',
      'buttonText': 'Get started now',
    },
    {
      'title': 'Sign with a single touch',
      'description': 'Quickly sign your documents digitally with just a single touch on your screen.',
      'buttonText': 'Get started now',
    },
    {
      'title': 'Easy, secure payment',
      'description': 'Enjoy fast electronic payments with high security and ease of use.',
      'buttonText': 'Get started now',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingScreen(
                title: _onboardingData[index]['title']!,
                description: _onboardingData[index]['description']!,
                pageController: _pageController,
                currentIndex: index,
                totalScreens: _onboardingData.length,
                buttonText: _onboardingData[index]['buttonText']!,
              );
            },
          ),
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => buildDot(index, context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      height: 8,
      width: _currentPage == index ? 24 : 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentPage == index ? primaryColor : const Color(0xFFE0E0E0),
      ),
    );
  }
}

// Placeholder for home screen
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home Screen'),
      ),
    );
  }
}