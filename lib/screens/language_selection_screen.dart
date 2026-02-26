import 'package:flutter/material.dart';
import 'package:bankid_app/screens/national_id_verification_screen.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/providers/language_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    final currentCode =
        Provider.of<LanguageProvider>(context, listen: false).currentLocale.languageCode;
    _selectedLanguageCode = currentCode;
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Directionality(
      textDirection: languageProvider.isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                const Spacer(), // Add this line to center the language options vertically

                // 🔹 Title
                SizedBox(
                  width: double.infinity, // Ensure the Text widget takes full width
                  child: Text(
                    AppLocalizations.of(context)?.languageSelectionTitle ??
                        'Choose your language',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                          color: const Color(0xFF172A47),
                        ),
                    textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                  ),
                ),
                SizedBox(height: 20.h),

                // 🔹 Language options
                _buildLanguageOption(
                  AppLocalizations.of(context)?.languageEnglish ?? 'English',
                  'en',
                  primaryColor,
                ),
                _buildLanguageOption(
                  AppLocalizations.of(context)?.languageArabic ?? 'Arabic',
                  'ar',
                  primaryColor,
                ),

                const Spacer(), // Add this line to center the language options vertically

                // 🔹 Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const NationalIdVerificationScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.continueButton ?? 'Continue',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String label, String localeCode, Color primaryColor) {
    final isSelected = _selectedLanguageCode == localeCode;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? primaryColor : const Color(0xFFE0E0E0),
          width: isSelected ? 2.0.w : 1.0.w,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLanguageCode = localeCode;
          });
          Provider.of<LanguageProvider>(context, listen: false)
              .changeLanguage(Locale(localeCode));
        },
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w300,
                color: isSelected
                    ? const Color(0xFF212B36)
                    : const Color(0xFF919EAB),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isSelected)
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 16.sp),
            ),
        ],
      ),
        ),
      ),
    );
  }
}
