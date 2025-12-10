import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bankid_app/screens/settings_screen.dart';
import 'package:bankid_app/screens/history_screen.dart';
import 'package:bankid_app/screens/id_card_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _homeWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/logo.svg',
              height: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'Protect your BankID',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.keepDigitalIdentitySecure,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF637381),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 96),
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFB0BEC5)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedQrCode01,
                size: 18,
                color: Color(0xFF212B36),
              ),
              label: Text(
                AppLocalizations.of(context)!.scanTheQrCode,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212B36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  late final List<Widget> _widgetOptions = <Widget>[
    _homeWidget(),
    const HistoryScreen(),
    const IDCardScreen(),
    // const ProfileScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFDC3545),
        unselectedItemColor: const Color(0xFF9AA5B1),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          _navItem(HugeIcons.strokeRoundedHome01, AppLocalizations.of(context)!.home, 0),
          _navItem(HugeIcons.strokeRoundedClock04, AppLocalizations.of(context)!.history, 1),
          _navItem(HugeIcons.strokeRoundedId, AppLocalizations.of(context)!.idCard, 2),
          _navItem(HugeIcons.strokeRoundedSettings01, AppLocalizations.of(context)!.settings, 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem(List<List<dynamic>> iconData, String label, int index) {
    return BottomNavigationBarItem(
      icon: HugeIcon(
        icon: iconData,
        color: _selectedIndex == index
            ? const Color(0xFFDC3545)
            : const Color(0xFF9AA5B1),
      ),
      label: label,
    );
  }
}
