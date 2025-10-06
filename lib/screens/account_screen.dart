import 'package:bankid_app/screens/id_card_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bankid_app/screens/edit_phone_number_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool isVerified;
  const ProfileScreen({super.key, this.isVerified = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Red Header
            Container(
              height: 120,
              width: double.infinity,
              color: const Color(0xFFCE2436),
            ),

            // Profile Card (overlapping header)
            Transform.translate(
              offset: const Offset(0, -50),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                        'assets/images/selfie_placeholder.png',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ayham Mahmoud Azeemah',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '711025–1357',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              HugeIcon(
                                icon: isVerified
                                    ? HugeIcons.strokeRoundedCheckmarkBadge01
                                    : HugeIcons.strokeRoundedShield01,
                                color: isVerified
                                    ? const Color(0xFF22C55E)
                                    : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isVerified
                                    ? 'Verified Account'
                                    : 'Not Verified',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isVerified
                                      ? const Color(0xFF22C55E)
                                      : Colors.red,
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

            // Account Info Card
            Transform.translate(
              offset: const Offset(0, -36),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoField(
                      context,
                      'Phone Number',
                      '+999 999 999 999',
                      editable: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditPhoneNumberScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _infoField(context, 'Gender', 'Male'),
                    const SizedBox(height: 12),
                    _infoField(context, 'Date of Birth', '10/25/1971'),
                    const SizedBox(height: 12),
                    _infoField(context, 'Nationality', 'British'),
                    const SizedBox(height: 12),
                    _infoField(context, 'National ID Number', '71105350328'),
                    const SizedBox(height: 12),
                    _infoField(context, 'Date of Issue', '01/19/2022'),
                    const SizedBox(height: 12),
                    _infoField(context, 'Date of Expiration', '01/19/2027'),
                    const SizedBox(height: 16),

                    // ID Card Image Section
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F7FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedIdentityCard,
                              color: Colors.black54,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ID Card Image',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Image389074292303.JPEG',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF111827),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const IDCardViewerScreen(),
                              ),
                            ),
                            icon: const Icon(
                              Icons.remove_red_eye_outlined,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoField(
    BuildContext context,
    String label,
    String value, {
    bool editable = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
              ),
            ),
            if (editable) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedPencilEdit02,
                    size: 20,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
