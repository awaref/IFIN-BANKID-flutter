import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          "Terms of Use",
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
                "The terms of use for our app are a set of rules that users must adhere to when using the app. By downloading and using the app, you agree to comply with these terms.",
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
                      text: "1. ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "**Acceptance of Terms**: By using the app, you agree to all the terms and conditions stated herein. If you do not agree to any of these terms, you must not use the app.",
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
                      text: "2. ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "**Registration**: You may need to create an account to use certain features of the app. You must provide accurate and complete information when registering, and you are responsible for keeping your account information confidential.",
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
                      text: "3. ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "**Permitted Use**: You must use the app only for lawful purposes and in accordance with all applicable laws. You are not permitted to use the app in ways that may infringe on the rights of others or harm the app.",
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
                      text: "4. ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "**Security**: We take the security of your data seriously. You must take all necessary precautions to protect your account information and passwords. If you suspect any unauthorized use of your account, you must notify us immediately.",
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
                      text: "5. ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "**Changes to Terms**: We reserve the right to modify the terms of use at any time. You will be notified of any significant changes, and your continued use of the app after such changes will",
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
