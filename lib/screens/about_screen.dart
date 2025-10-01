import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          "About the App",
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
                "Our app is your ideal digital identity that simplifies payment and electronic signature processes. "
                "The app allows you to carry out financial transactions easily and securely, saving you time and effort. "
                "With its modern interface, you can manage your payments and sign documents anywhere, anytime. "
                "We are committed to providing a seamless user experience, where you can easily access all features. "
                "We continuously develop the app, listening to your feedback to improve performance and add new features that meet your needs. "
                "Join us today and enjoy a comprehensive digital experience that simplifies your life!",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "We believe that technology should be accessible to everyone, so we designed the app to be user-friendly, even for new users. "
                "Additionally, the app offers multiple payment options, allowing you to choose the method that suits you best. "
                "Whether you prefer to pay via credit cards, digital wallets, or even bank transfers, we cover all options.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "We also work to enhance the security of your data through advanced encryption technologies, "
                "ensuring that your personal and financial information is fully protected. "
                "We understand that security is a top priority, so we are committed to providing a safe environment for all our users.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "V 1.0",
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
