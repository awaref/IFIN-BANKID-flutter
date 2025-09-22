import 'package:flutter/material.dart';
import 'package:bankid_app/screens/selfie_video_screen.dart';
import 'package:hugeicons/hugeicons.dart';

class IdAppIdentityScreen extends StatelessWidget {
  const IdAppIdentityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Let\'s create your ID App identity.',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: const Color(0xFF172A47),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5EE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color.fromRGBO(239, 116, 34, 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color.fromRGBO(239, 116, 34, 1),
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Performing this process ',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: const Color.fromRGBO(239, 116, 34, 1),
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                          TextSpan(
                            text: 'for fun or as a test',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: const Color.fromRGBO(239, 116, 34, 1),
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                          TextSpan(
                            text: ' may result in you being permanently blocked and can prohibit you from using ID App.',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: const Color(0xFFEF7422),
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Follow these steps',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.6
              ),
            ),
            const SizedBox(height: 8),
            _buildMethodOption(
              context,
              icon: Icons.face_outlined,
              title: 'Take a selfie video',
            ),
            _buildMethodOption(
              context,
              icon: Icons.credit_card_outlined,
              title: 'Take a photo of your National ID card',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SelfieVideoScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Start Enrollment',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16
                  ),
                ),
              ),
            ),
            SizedBox(height: 64,)
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}