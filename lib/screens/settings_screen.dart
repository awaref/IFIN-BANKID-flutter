import 'package:bankid_app/screens/about_screen.dart' show AboutScreen;
import 'package:bankid_app/screens/privacy_screen.dart';
import 'package:bankid_app/screens/terms_screen.dart';
import 'package:bankid_app/screens/two_factor_auth_screen.dart';
import 'package:bankid_app/services/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:bankid_app/screens/delete_account_screen.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/providers/language_provider.dart';
import 'package:bankid_app/screens/digital_signatures_list_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isBiometricEnabled = false;
  bool _isLoadingBiometric = true;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final enabled = await _biometricService.isBiometricEnabledByUser();
    if (mounted) {
      setState(() {
        _isBiometricEnabled = enabled;
        _isLoadingBiometric = false;
      });
    }
  }

  Future<void> _toggleBiometric() async {
    if (_isBiometricEnabled) {
      // Turn off
      await _biometricService.setBiometricEnabled(false);
      setState(() => _isBiometricEnabled = false);
    } else {
      // Check if device supports it first
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.authenticationError),
          ), // fallback error message
        );
        return;
      }

      // Turn on - authenticate first to prove it's the owner
      final authenticated = await _biometricService.authenticate(
        reason: AppLocalizations.of(context)!.authenticateReason,
      );
      if (authenticated) {
        await _biometricService.setBiometricEnabled(true);
        if (mounted) {
          setState(() => _isBiometricEnabled = true);
        }
      }
    }
  }

  static final TextStyle _rubikTextStyle = GoogleFonts.rubik(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    height: 1.0,
    letterSpacing: 0,
  );

  static final TextStyle _rubikAppBarTextStyle = GoogleFonts.rubik(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
    height: 1.0,
    letterSpacing: 0,
    color: const Color(0xFF172A47),
  );

  void _showLanguagePopup() {
    final primaryColor = Theme.of(context).primaryColor;

    // Get current language from provider
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    String? tempSelectedLanguageCode =
        languageProvider.currentLocale.languageCode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.languageSelectionTitle,
                    style: _rubikAppBarTextStyle,
                  ),
                  const SizedBox(height: 20),

                  // Language options using the same style as language_selection_screen
                  _buildLanguageOption(
                    context,
                    AppLocalizations.of(context)!.languageEnglish,
                    'en',
                    primaryColor,
                    tempSelectedLanguageCode,
                    (code) {
                      setModalState(() {
                        tempSelectedLanguageCode = code;
                      });
                    },
                  ),
                  _buildLanguageOption(
                    context,
                    AppLocalizations.of(context)!.languageArabic,
                    'ar',
                    primaryColor,
                    tempSelectedLanguageCode,
                    (code) {
                      setModalState(() {
                        tempSelectedLanguageCode = code;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Buttons row
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Save changes button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (tempSelectedLanguageCode != null) {
                              // Apply language change using the provider
                              languageProvider.changeLanguage(
                                Locale(tempSelectedLanguageCode!),
                              );

                              // Update the UI state
                              setState(() {
                                // Variable removed
                              });
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.saveChanges,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    String localeCode,
    Color primaryColor,
    String? selectedLanguageCode,
    Function(String) onSelect,
  ) {
    final isSelected = selectedLanguageCode == localeCode;

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
        onTap: () => onSelect(localeCode),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w300,
                  color: isSelected
                      ? const Color(0xFF212B36)
                      : const Color(0xFF919EAB),
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
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
          style: _rubikAppBarTextStyle,
        ),
      ),
      body: ListView(
        children: [
          // General Settings
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context)!.generalSettingsTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.merge(_rubikTextStyle),
            ),
          ),
          ListTile(
            leading: const HugeIcon(icon: HugeIcons.strokeRoundedFingerPrint),
            title: Text(
              AppLocalizations.of(context)!.appFingerprintTitle,
              style: _rubikTextStyle,
            ),
            trailing: _isLoadingBiometric
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: _toggleBiometric,
                    child: Text(
                      _isBiometricEnabled
                          ? AppLocalizations.of(context)!.turnOff
                          : AppLocalizations.of(context)!.turnOn,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF637381),
                      ),
                    ),
                  ),
          ),
          ListTile(
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedLanguageSkill,
              size: 20.0,
            ),
            title: Text(
              AppLocalizations.of(context)!.appLanguageTitle,
              style: _rubikTextStyle,
            ),
            onTap: _showLanguagePopup,
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedHeadset,
              size: 20.0,
            ),
            title: Text(
              AppLocalizations.of(context)!.helpAndSupportTitle,
              style: _rubikTextStyle,
            ),
          ),
          ListTile(
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedInformationCircle,
              size: 20.0,
            ),
            title: Text(
              AppLocalizations.of(context)!.aboutTheAppTitle,
              style: _rubikTextStyle,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            ),
          ),
          ListTile(
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedInformationCircle,
              size: 20.0,
            ),
            title: Text(
              AppLocalizations.of(context)!.termsOfUseTitle,
              style: _rubikTextStyle,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TermsScreen()),
            ),
          ),
          ListTile(
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedInformationCircle,
              size: 20.0,
            ),
            title: Text(
              AppLocalizations.of(context)!.privacyPolicyTitle,
              style: _rubikTextStyle,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyScreen()),
            ),
          ),

          // Account Settings
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context)!.accountSettingsTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.merge(_rubikTextStyle),
            ),
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedTwoFactorAccess,
              size: 20.0,
            ),
            title: Text(
              AppLocalizations.of(context)!.twoFactorAuthenticationTitle,
              style: _rubikTextStyle,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TwoFactorAuthScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedSignature,
              size: 20.0,
            ),
            title: Text(
              AppLocalizations.of(context)!.digitalSignaturesListTitle,
              style: _rubikTextStyle,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DigitalSignaturesListScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedLock,
              size: 20.0,
            ),
            title: Text(
              AppLocalizations.of(context)!.changePasswordTitle,
              style: _rubikTextStyle,
            ),
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedClock04,
              size: 20.0,
            ),
            title: Text(
              AppLocalizations.of(context)!.transactionHistoryTitle,
              style: _rubikTextStyle,
            ),
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedPassport,
              size: 20.0,
            ),
            title: Text(
              AppLocalizations.of(context)!.idCardTitle,
              style: _rubikTextStyle,
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.idCardSubtitle,
              style: _rubikTextStyle.copyWith(
                fontSize: 12,
                color: const Color(0xFF919EAB),
              ),
            ),
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedDelete01,
              color: Colors.red,
              size: 20.0,
            ),
            title: Text(
              AppLocalizations.of(context)!.deleteAccountTitle,
              style: _rubikTextStyle.copyWith(color: Colors.red),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeleteAccountScreen(),
                ),
              );
            },
          ),

          // New Account
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context)!.newAccountSectionTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.merge(_rubikTextStyle),
            ),
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              size: 20.0,
            ),
            title: Text(
              AppLocalizations.of(context)!.addNewAccountTitle,
              style: _rubikTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
