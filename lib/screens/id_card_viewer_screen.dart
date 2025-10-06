import 'package:flutter/material.dart';

class IDCardViewerScreen extends StatelessWidget {
  const IDCardViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6F6F7A),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: Column(
                  children: [
                    _idImagePlaceholder(),
                    const SizedBox(height: 16),
                    _idImagePlaceholder(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _idImagePlaceholder() {
    return Container(
      width: 320,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)],
        image: const DecorationImage(
          image: AssetImage('assets/images/selfie_placeholder.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
