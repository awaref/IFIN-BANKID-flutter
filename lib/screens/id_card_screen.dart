import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:qr_flutter/qr_flutter.dart';

class IDCardScreen extends StatelessWidget {
  const IDCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEEF5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            Container(
              width: double.infinity,
              height: 130,
              color: const Color(0xFFD01F39),
            ),

            // Card containers
            Transform.translate(
              offset: const Offset(0, -60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // ===== First white container =====
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 24,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 140),
                                const Text(
                                  'Ayham Mahmoud Azeemah',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF212B36),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  '711025–1357',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF637381),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                                      size: 20,
                                      color: Color(0xFF10B67E),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Verified Account',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF10B67E),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 0,
                          
                            child: Image.asset(
                              'assets/images/oman_emblem.png',
                              width: 194,
                            ),
                        ),
                        // Profile image
                        Positioned(
                          top: -47,
                          child: Container(
                            width: 190,
                            height: 190,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/images/selfie_placeholder.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ===== Second white container =====
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            child: Column(
                              children: [
                                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD01F39).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Text(
                                  'Scan using the Digital ID app',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFEF4444),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                    ),
                                
                                const SizedBox(height: 16),
                                QrImageView(
                                  data:
                                      'Image, Name, and Personal ID Number: Ayham Mahmoud Azeemah - 711025–1357',
                                  version: QrVersions.auto,
                                  size: 130.0,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Share via QR code:\nImage, Name, and Personal ID Number',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
