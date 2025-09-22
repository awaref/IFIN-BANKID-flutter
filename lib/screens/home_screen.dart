import 'package:flutter/material.dart';
import 'package:bankid_app/screens/digital_signatures_list_screen.dart';
import 'package:bankid_app/screens/national_id_card_screen.dart';
import 'package:bankid_app/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // For bottom navigation bar
  late Color primaryColor;

  @override
  void initState() {
     super.initState();
  }
 
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on index
    if (index == 0) {
      // Home
    } else if (index == 1) {
      // History
    } else if (index == 2) {
      // ID Card
    } else if (index == 3) {
      // Account
    } else if (index == 4) {
      // Settings
    }
  }

  @override
  Widget build(BuildContext context) {
    primaryColor = Theme.of(context).primaryColor;
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0, // Hide default app bar
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: languageProvider.isRTL ? TextDirection.rtl : TextDirection.ltr,
            children: [
              // Top section with user info
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC3545), // Red background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // User image placeholder (use HugeIcons instead of SVG)
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedUserCircle,
                      color: Colors.white,
                      size: 60,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ayham Mahmoud Azeemah',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '711025-1357',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedUserCheck01,
                              color: const Color(0xFF37C293),
                              size: 24,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verified Account',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Digital Signatures section
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const DigitalSignaturesListScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedSignature,
                        color: const Color(0xFFDC3545),
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Digital Signatures',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            Text(
                              'Uploaded Documents and Files',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Scan QR Code button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle QR code scan
                  },
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedQrCode01, color: Colors.white),
                  label: Text(
                    'Scan the QR Code',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28A745), // Green background
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Security message
              Text(
                'Keep your digital identity secure. Do not share it or use it at someone\'s request.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedHome01,
              color: _selectedIndex == 0 ? primaryColor : const Color(0xFF9AA5B1),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedWorkHistory,
              color: _selectedIndex == 1 ? primaryColor : const Color(0xFF9AA5B1),
            ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedCreditCard,
              color: _selectedIndex == 2 ? primaryColor : const Color(0xFF9AA5B1),
            ),
            label: 'Cards',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              color: _selectedIndex == 3 ? primaryColor : const Color(0xFF9AA5B1),
            ),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSettings01,
              color: _selectedIndex == 4 ? primaryColor : const Color(0xFF9AA5B1),
            ),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
