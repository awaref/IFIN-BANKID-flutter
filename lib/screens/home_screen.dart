import 'package:flutter/material.dart';
import 'package:bankid_app/screens/digital_signatures_list_screen.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bankid_app/screens/settings_screen.dart';
import 'package:bankid_app/screens/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Widget for the Home tab content
  Widget _homeWidget() {
    return Column(
      children: [
        // 🔴 Header Section
        Container(
          width: double.infinity,
          height: 171, // Adjusted height for the red background
          decoration: const BoxDecoration(
            color: Color(0xFFD01F39),
          ),
          child: Stack(
            clipBehavior: Clip.none, // Allows children to overflow
            children: [
              Positioned(
                top: 72, // Position the white box
                left: 16,
                right: 16,
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  height: 179, // Keep original height for now
                  padding: const EdgeInsets.only(
                      top: 69, right: 16, bottom: 16, left: 16), // Adjusted padding for profile picture
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row( // Changed back to Row to align with image
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 0), // Space for profile picture
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Ayham Mahmoud Azeemah",
                              style: TextStyle(
                                color: Color(0xFF212B36),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "711025-1357",
                              style: TextStyle(
                                color: Color(0xFF637381),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: const [
                                Icon(Icons.verified,
                                    color: Color(0xFF10B67E), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Verified Account",
                                  style: TextStyle(
                                    color: Color(0xFF10B67E),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 53, // Position the profile picture
                left: 28,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: AssetImage('assets/images/selfie_placeholder.png'), // Replace with actual image asset
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 89), // Adjusted height to push content down

        // 📄 Digital Signatures Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const DigitalSignaturesListScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedSignature,
                    color: Color(0xFF37C293),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Digital Signatures",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Uploaded Documents and Files",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.grey, size: 16),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 111),

        // 📷 Scan QR Code Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: const Color(0xFF37C293),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedQrCode01,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Scan the QR Code",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 18),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Security note
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 31),
          child: Text(
            "Keep your digital identity secure. Do not share it or use it at someone else's request.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF212B36),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  late final List<Widget> _widgetOptions = <Widget>[
    _homeWidget(), // Home Screen
    const HistoryScreen(), // Placeholder for History
    const Text('ID Card Page'), // Placeholder for ID Card
    const Text('Account Page'), // Placeholder for Account
    const SettingsScreen(), // Settings Screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: _widgetOptions.elementAt(_selectedIndex),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFDC3545),
        unselectedItemColor: const Color(0xFF9AA5B1),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedHome01,
                color: _selectedIndex == 0 ? const Color(0xFFDC3545) : const Color(0xFF9AA5B1),
              ),
              label: "Home"),
          BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedClock04,
                color: _selectedIndex == 1
                        ? const Color(0xFFDC3545)
                        : const Color(0xFF9AA5B1),
              ),
              label: "History"),
          BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedId,
                color: _selectedIndex == 2 ? const Color(0xFFDC3545) : const Color(0xFF9AA5B1),
              ),
              label: "ID Card"),
          BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                color: _selectedIndex == 3 ? const Color(0xFFDC3545) : const Color(0xFF9AA5B1),
              ),
              label: "Account"),
          BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedSettings01,
                color: _selectedIndex == 4 ? const Color(0xFFDC3545) : const Color(0xFF9AA5B1),
              ),
              label: "Settings"),
        ],
      ),
    );
  }
}
