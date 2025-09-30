import 'package:flutter/material.dart';
import 'package:bankid_app/screens/delete_account_screen.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

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
    if (!mounted) {
      return;
    }

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
    if (!mounted) {
      return;
    }

    setState(
      () => _authorized = authenticated ? 'Authorized' : 'Not Authorized',
    );
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  static final TextStyle _rubikTextStyle = GoogleFonts.rubik(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    height: 1.0, // Equivalent to line-height 100%
    letterSpacing: 0, // Equivalent to letter-spacing 0%
  );

  static final TextStyle _rubikAppBarTextStyle = GoogleFonts.rubik(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
    height: 1.0,
    letterSpacing: 0,
    color: const Color(0xFF172A47),
  );

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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.merge(_rubikTextStyle),
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
            title: Text('Language', style: _rubikTextStyle),
            onTap: () {
              // Navigate to Language selection
            },
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedHeadset,
              size: 20.0,
            ),
            title: Text('Help and Support', style: _rubikTextStyle),
            onTap: () {
              // Navigate to Help and Support
            },
          ),
          ListTile(
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedInformationCircle,
              size: 20.0,
            ),
            title: Text('About the App', style: _rubikTextStyle),
            onTap: () {
              // Navigate to About the App
            },
          ),
          ListTile(
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedInformationCircle,
              size: 20.0,
            ),
            title: Text('Terms of Use', style: _rubikTextStyle),
            onTap: () {
              // Navigate to Terms of Use
            },
          ),
          ListTile(
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedInformationCircle,
              size: 20.0,
            ),
            title: Text('Privacy Policy', style: _rubikTextStyle),
            onTap: () {
              // Navigate to Privacy Policy
            },
          ),

          // Account Settings
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Account Settings',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.merge(_rubikTextStyle),
            ),
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedLock,
              size: 20.0,
            ),
            title: Text('Change Password', style: _rubikTextStyle),
            onTap: () {
              // Navigate to Change Password screen
            },
          ),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedClock04,
              size: 20.0,
            ),
            title: Text('Transaction History', style: _rubikTextStyle),
            onTap: () {
              // Navigate to Transaction History screen
            },
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
            onTap: () {
              // Navigate to ID Card management
            },
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
              'New',
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
            title: Text('Add New Account', style: _rubikTextStyle),
            onTap: () {
              // Navigate to Add New Account screen
            },
          ),
        ],
      ),
    );
  }
}
