import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Our app's privacy policy aims to protect your personal information and ensure its secure use. We are committed to safeguarding your privacy and would like to inform you about how we collect and use the information you provide us when using the app.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: "1. Information We Collect",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ": When you use the app, we may collect personal information such as your name, email address, and phone number. We may also collect non-personal information such as usage data and statistics to enhance your experience.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: "2. How We Use the Information",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ": We use the information we collect to provide better services to you, such as personalizing content, improving performance, and communicating with you about updates and new offers. We will not share your information with any third party without your consent, unless required by law.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: "3. Information Protection",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ": We take appropriate security measures to protect your information from unauthorized access or illegal use. Information is stored in secure environments, and we use encryption technologies to protect sensitive data.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: "4. Your Rights",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ": You have the right to access your personal information and correct or delete it. You may also object to the processing of your data or request its transfer. If you have any questions about your rights, please contact us.",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
