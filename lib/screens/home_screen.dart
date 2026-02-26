import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/models/contract.dart';
import 'package:bankid_app/screens/history_screen.dart';
import 'package:bankid_app/screens/id_card_screen.dart';
import 'package:bankid_app/screens/qr_scanner_screen.dart';
import 'package:bankid_app/screens/settings_screen.dart';
import 'package:bankid_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Contract> _pendingContracts = [];
  int _pendingContractsCount = 0;
  bool _isLoadingNotifications = false;
  String? _notificationError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedIndex == 0) _fetchPendingContracts();
  }

  Future<void> _fetchPendingContracts() async {
    if (!mounted) return;

    setState(() {
      _isLoadingNotifications = true;
      _notificationError = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final contracts =
          await apiService.fetchContracts(status: 'pending_signature');

      if (!mounted) return;

      setState(() {
        _pendingContracts = contracts;
        _pendingContractsCount = contracts.length;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _notificationError =
            AppLocalizations.of(context)!.failedToLoadNotifications;
        _isLoadingNotifications = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) _fetchPendingContracts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeContent(),
      const HistoryScreen(),
      const IDCardScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      appBar: _selectedIndex == 0 ? _buildHomeAppBar(context) : null,
      body: screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildHomeAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: PopupMenuButton<Contract>(
            onOpened: _fetchPendingContracts,
            itemBuilder: (_) => _buildNotificationMenu(l10n),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedNotification01,
                  size: 28.sp,
                  color: const Color(0xFF212B36),
                ),
                if (_pendingContractsCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC62828),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '$_pendingContractsCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PopupMenuEntry<Contract>> _buildNotificationMenu(
      AppLocalizations l10n) {
    if (_isLoadingNotifications) {
      return [
        PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10.w),
              Text(l10n.loading),
            ],
          ),
        ),
      ];
    }

    if (_notificationError != null) {
      return [
        PopupMenuItem(
          enabled: false,
          child: Text(_notificationError!),
        ),
      ];
    }

    if (_pendingContracts.isEmpty) {
      return [
        PopupMenuItem(
          enabled: false,
          child: Text(l10n.noPendingContracts),
        ),
      ];
    }

    return _pendingContracts.map((contract) {
      return PopupMenuItem<Contract>(
        value: contract,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contract.title,
              style:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              'ID: ${contract.id}',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to contract details
        },
      );
    }).toList();
  }

  Widget _buildHomeContent() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/images/logo.svg',
                height: 120.h,
              ),
              SizedBox(height: 24.h),
              Text(
                'Protect your BankID',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                l10n.keepDigitalIdentitySecure,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF637381),
                ),
              ),
              SizedBox(height: 40.h),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedQrCode01,
                  size: 18.sp,
                ),
                label: Text(
                  l10n.scanTheQrCode,
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: const Color(0xFFDC3545),
      unselectedItemColor: const Color(0xFF9AA5B1),
      items: [
        _navItem(HugeIcons.strokeRoundedHome01, l10n.home, 0),
        _navItem(HugeIcons.strokeRoundedClock04, l10n.history, 1),
        _navItem(HugeIcons.strokeRoundedId, l10n.idCard, 2),
        _navItem(HugeIcons.strokeRoundedSettings01, l10n.settings, 3),
      ],
    );
  }

  BottomNavigationBarItem _navItem(
      List<List<dynamic>> iconData, String label, int index) {
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