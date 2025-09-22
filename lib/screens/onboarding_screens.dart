import 'package:flutter/material.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/screens/app_protection_screen.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212B36),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF637381),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
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
        'description': localizations?.onboardingDesc1 ??
            'Easily verify your personal identity and get comprehensive protection for all your data.',
      },
      {
        'title': localizations?.onboardingTitle2 ?? 'Sign with a single touch',
        'description': localizations?.onboardingDesc2 ??
            'Quickly sign your documents digitally with just a single touch on your screen.',
      },
      {
        'title': localizations?.onboardingTitle3 ?? 'Easy, secure payment',
        'description': localizations?.onboardingDesc3 ??
            'Enjoy fast electronic payments with high security and ease of use.',
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

  void _onButtonPressed(BuildContext context, int totalPages) {
    if (_currentPage == totalPages - 1) {
      // Last screen → go to next flow
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AppProtectionScreen()),
      );
    } else {
      // Go to next onboarding page
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = _isRTL(context);
    final onboardingData = _getLocalizedData(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              reverse: isRTL,
              onPageChanged: (page) {
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
          ),

          // Progress Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
              (index) => buildDot(index),
            ),
          ),

          const SizedBox(height: 94),

          // Button (always visible, full width)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: double.infinity, // full width
              child: ElevatedButton(
                onPressed: () => _onButtonPressed(context, onboardingData.length),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF37C293),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
          ),

          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 5,
      width: _currentPage == index ? 67 : 18.5,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentPage == index
            ? const Color(0xFFD01F39)
            : const Color(0xFFEFEEF5),
      ),
    );
  }
}
