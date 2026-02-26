import 'package:flutter/material.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/screens/app_protection_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF212B36),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF637381),
              height: 1.5,
            ),
          ),
          SizedBox(height: 40.h),
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
      body: SafeArea(
        child: Column(
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

            SizedBox(height: 94.h),

            // Button (always visible, full width)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: SizedBox(
                width: double.infinity, // full width
                child: ElevatedButton(
                  onPressed: () => _onButtonPressed(context, onboardingData.length),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF37C293),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.getStartedButton ?? 'Get started now',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 64.h),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 5.h,
      width: _currentPage == index ? 67.w : 18.5.w,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: _currentPage == index
            ? const Color(0xFFD01F39)
            : const Color(0xFFEFEEF5),
      ),
    );
  }
}
