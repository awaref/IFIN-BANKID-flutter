import 'package:flutter/material.dart';
import 'package:bankid_app/screens/home_screen.dart'; // Import home_screen.dart
import 'package:hugeicons/hugeicons.dart';

class CheckInformationScreen extends StatelessWidget {
  const CheckInformationScreen({super.key});

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
        child: SingleChildScrollView( // ✅ allows scrolling instead of overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Check your information.',
                style: const TextStyle(
                  color: Color(0xFF172a47),
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),

              /// ✅ Row with flexible images
              Row(
                children: [
                  Expanded(child: _buildImagePlaceholder()),
                  const SizedBox(width: 8),
                  Expanded(child: _buildImagePlaceholder()),
                ],
              ),
              const SizedBox(height: 16),

              _buildInfoRow('First Name', 'AYHAM'),
              _buildDivider(),
              _buildInfoRow('Last Name', 'AZEEMAH'),
              _buildDivider(),
              _buildInfoRow('Gender', 'Male'),
              _buildDivider(),
              _buildInfoRow('Date of Birth', '25/10/1971'),
              _buildDivider(),
              _buildInfoRow('Nationality', 'British'),
              _buildDivider(),
              _buildInfoRow('National ID number', '71105350328'),
              _buildDivider(),
              _buildInfoRow('Date of Issue', '19/01/2022'),
              _buildDivider(),
              _buildInfoRow('Date of expiry', '19/01/2027'),

              const SizedBox(height: 32),

              /// Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF37C293),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9, // ✅ keeps images proportional
      child: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/selfie_placeholder.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF637381)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF212B36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(
        color: const Color(0xFF919EAB).withOpacity(0.2),
        thickness: 1.0,
        height: 0.0,
      ),
    );
  }
}
