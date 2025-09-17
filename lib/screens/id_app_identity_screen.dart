import 'package:flutter/material.dart';
import 'package:bankid_app/screens/selfie_video_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IdAppIdentityScreen extends StatelessWidget {
  const IdAppIdentityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Let\'s create your ID App identity.'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(239, 116, 34, 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color.fromRGBO(239, 116, 34, 1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color.fromRGBO(239, 116, 34, 1)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Performing this process for fun or as a test may result in you being permanently blocked and can prohibit you from using ID App.',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: const Color.fromRGBO(239, 116, 34, 1)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Follow these steps',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 4),
            _buildMethodOption(
              context,
              iconPath: 'assets/images/selfie_placeholder.svg',
              title: 'Take a selfie video',
            ),
            const SizedBox(height: 0),
            _buildMethodOption(
              context,
              iconPath: 'assets/images/id_card_placeholder.svg',
              title: 'Take a photo of your National ID card',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const SelfieVideoScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Start Enrollment',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption(
    BuildContext context, {
    required String iconPath,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SvgPicture.asset(iconPath, width: 40, height: 40, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}