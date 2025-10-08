import 'package:bankid_app/screens/about_screen.dart' show AboutScreen;
import 'package:bankid_app/screens/privacy_screen.dart';
import 'package:bankid_app/screens/terms_screen.dart';
import 'package:bankid_app/screens/two_factor_auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:bankid_app/screens/delete_account_screen.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/providers/language_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  String _selectedLanguage = "English"; // Default language

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or other biometric) to authenticate',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) return;

    setState(() =>
        _authorized = authenticated ? 'Authorized' : 'Not Authorized');
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
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
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    String? tempSelectedLanguageCode = languageProvider.currentLocale.languageCode;
    
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
                    AppLocalizations.of(context)?.languageSelectionTitle ?? 'Choose your language',
                    style: _rubikAppBarTextStyle,
                  ),
                  const SizedBox(height: 20),
                  
                  // Language options using the same style as language_selection_screen
                  _buildLanguageOption(
                    context,
                    AppLocalizations.of(context)?.languageEnglish ?? 'English',
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
                    AppLocalizations.of(context)?.languageArabic ?? 'Arabic',
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
                          child: Text(
                            AppLocalizations.of(context)?.cancel ?? 'Cancel',
                            style: GoogleFonts.rubik(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Save changes button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (tempSelectedLanguageCode != null) {
                              // Apply language change using the provider
                              languageProvider.changeLanguage(Locale(tempSelectedLanguageCode!));
                              
                              // Update the UI state
                              setState(() {
                                _selectedLanguage = tempSelectedLanguageCode == 'en' ? 'English' : 'Arabic';
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
                            AppLocalizations.of(context)?.saveChanges ?? 'Save changes',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
                  color: isSelected ? const Color(0xFF212B36) : const Color(0xFF919EAB),
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
        title: Text('Settings', style: _rubikAppBarTextStyle),
      ),
      body: ListView(
        children: [
          // General Settings
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'General Settings',
              style: Theme.of(context).textTheme.titleLarge?.merge(_rubikTextStyle),
            ),
          ),
          ListTile(
            leading: const HugeIcon(icon: HugeIcons.strokeRoundedFingerPrint),
            title: Text('App Fingerprint', style: _rubikTextStyle),
            trailing: TextButton(
              onPressed: () {
                if (_authorized == 'Authorized') {
                  _cancelAuthentication();
                } else {
                  _authenticate();
                }
              },
              child: Text(
                _authorized == 'Authorized' ? 'Turn Off' : 'Turn On',
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
            title: Text('App Language', style: _rubikTextStyle),
            onTap: _showLanguagePopup,
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedHeadset,
              size: 20.0,
            ),
            title: Text('Help and Support', style: _rubikTextStyle),
          ),
          ListTile(
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedInformationCircle,
              size: 20.0,
            ),
            title: Text('About the App', style: _rubikTextStyle),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen())),

          ),
          ListTile(
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedInformationCircle,
              size: 20.0,
            ),
            title: Text('Terms of Use', style: _rubikTextStyle),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsScreen())),
          ),
          ListTile(
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedInformationCircle,
              size: 20.0,
            ),
            title: Text('Privacy Policy', style: _rubikTextStyle),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyScreen())),
          ),

          // Account Settings
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Account Settings',
              style: Theme.of(context).textTheme.titleLarge?.merge(_rubikTextStyle),
            ),
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedTwoFactorAccess,
              size: 20.0,
            ),
            title: Text('Two Factor Authentication', style: _rubikTextStyle),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TwoFactorAuthScreen())),
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedLock,
              size: 20.0,
            ),
            title: Text('Change Password', style: _rubikTextStyle),
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedClock04,
              size: 20.0,
            ),
            title: Text('Transaction History', style: _rubikTextStyle),
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedPassport,
              size: 20.0,
            ),
            title: Text('ID Card', style: _rubikTextStyle),
            subtitle: Text(
              'Manage your personal identity. Learn more about how to do it.',
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
              'Delete Account',
              style: _rubikTextStyle.copyWith(color: Colors.red),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DeleteAccountScreen()),
              );
            },
          ),

          // New Account
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'New',
              style: Theme.of(context).textTheme.titleLarge?.merge(_rubikTextStyle),
            ),
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              size: 20.0,
            ),
            title: Text('Add New Account', style: _rubikTextStyle),
          ),
        ],
      ),
    );
  }
}
