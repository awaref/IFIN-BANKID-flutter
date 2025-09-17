import 'package:bankid_app/screens/app_protection_screen.dart';
import 'package:flutter/material.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/screens/setup_passcode_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final String title;
  final String description;
  final bool isRTL;

  const OnboardingScreen({
    super.key,
    required this.title,
    required this.description,
    this.isRTL = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212B36),
            ),
          ),
          const SizedBox(height: 11),
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF637381),
              height: 1.5,
            ),
          ),
          const Spacer(),
        ],
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

  List<Map<String, String>> _getLocalizedData(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return [
      {
        'title': localizations?.onboardingTitle1 ?? 'Your digital identity is secure',
        'description': localizations?.onboardingDesc1 ?? 'Easily verify your personal identity and get comprehensive protection for all your data.',
      },
      {
        'title': localizations?.onboardingTitle2 ?? 'Sign with a single touch',
        'description': localizations?.onboardingDesc2 ?? 'Quickly sign your documents digitally with just a single touch on your screen.',
      },
      {
        'title': localizations?.onboardingTitle3 ?? 'Easy, secure payment',
        'description': localizations?.onboardingDesc3 ?? 'Enjoy fast electronic payments with high security and ease of use.',
      },
    ];
  }

  bool _isRTL(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = _isRTL(context);
    final onboardingData = _getLocalizedData(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            reverse: isRTL,
            onPageChanged: (int page) {
              setState(() => _currentPage = page);
            },
            itemBuilder: (context, index) {
              return OnboardingScreen(
                title: onboardingData[index]['title']!,
                description: onboardingData[index]['description']!,
                isRTL: isRTL,
              );
            },
          ),

          // Progress dots
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => buildDot(index),
              ),
            ),
          ),

          // Button (only on last page)
          if (_currentPage == onboardingData.length - 1)
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const AppProtectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF37C293),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)?.getStartedButton ?? 'Get started now',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: _currentPage == index ? 54 : 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentPage == index ? Colors.red[900] : const Color(0xFFE0E0E0),
      ),
    );
  }
}

// Placeholder Home Screen
/*
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
*/