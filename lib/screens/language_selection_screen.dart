import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bankid_app/screens/onboarding_screens.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/providers/language_provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage; // Will be set in initState based on current locale

  @override
  void initState() {
    super.initState();
    // Set initial selected language based on current locale
    _selectedLanguage = Provider.of<LanguageProvider>(context, listen: false).currentLocale.languageCode == 'ar' ? 'Arabic' : 'English';
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            // Use center alignment for better RTL/LTR support
            crossAxisAlignment: CrossAxisAlignment.center,
            textDirection: languageProvider.isRTL ? TextDirection.rtl : TextDirection.ltr,
            children: [
              // Logo at the top
              Center(
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  height: 60,
                  width: 60,
                ),
              ),
              const SizedBox(height: 60),
              // Language selection title
              Text(
                AppLocalizations.of(context)?.languageSelectionTitle ?? 'Choose your language',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),
              // Language options
              _buildLanguageOption(AppLocalizations.of(context)?.languageEnglish ?? 'English', 'en'),
              const SizedBox(height: 12),
              _buildLanguageOption(AppLocalizations.of(context)?.languageArabic ?? 'Arabic', 'ar'),
              const Spacer(),
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to onboarding flow
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const OnboardingFlow()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.continueButton ?? 'Continue',
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

  Widget _buildLanguageOption(String language, String localeCode) {
    final isSelected = _selectedLanguage == language;
    final primaryColor = Theme.of(context).primaryColor;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? primaryColor : const Color(0xFFE0E0E0),
          width: isSelected ? 2.0 : 1.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLanguage = language;
          });
          // Update app locale using the provider
          Provider.of<LanguageProvider>(context, listen: false)
              .changeLanguage(Locale(localeCode));
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            // Maintain proper spacing in both RTL and LTR
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: Provider.of<LanguageProvider>(context).isRTL ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Text(
                language,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? primaryColor : const Color(0xFF2C3E50),
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}