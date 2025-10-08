import 'package:bankid_app/screens/verify_pin_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ContractScreen(),
    );
  }
}

class ContractScreen extends StatelessWidget {
  const ContractScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Sign a contract',
          style: TextStyle(
            color: Color(0xFF1A1D3D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFE5E5E5)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Party One:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Name:', 'Ahmad Khaled Mustafa'),
                  const SizedBox(height: 8),
                  _buildInfoRow('ID/Passport Number:', 'SY24567891'),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Address:',
                    'Damascus – Dummar Project – Al-Yarmouk Street – Building No. 12',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Phone:', '+963 944 321 567'),
                  const SizedBox(height: 8),
                  _buildInfoRowWithLink(
                    'Email:',
                    'ahmad.mustafa@example.com',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Party Two:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Name:',
                    'Al-Noor Modern Technologies Company (represented by Mr. Samer Abdullah)',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Commercial Registration:',
                    '102547 – Damascus',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Address:',
                    'Damascus – Abu Rummaneh – Al-Jalaa Street – Building No. 8',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Phone:', '+963 944 654 789'),
                  const SizedBox(height: 8),
                  _buildInfoRowWithLink('Email:', 'info@alnoortech.com'),
                  const SizedBox(height: 24),
                  const Text(
                    'Contract Introduction:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Whereas Party One wishes to design and develop a mobile application for managing bookings, and whereas Party Two has the necessary expertise to implement this project, the parties have agreed as follows:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Article One – Subject of the Contract:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Party Two (Al-Noor Modern Technologies) undertakes to design and develop a mobile application that works on both Android and iOS systems, dedicated to managing and booking appointments, according to the specifications agreed upon with Party One.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Article Two – Duration of the Contract:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The duration of the contract starts from 15/08/2025 for a period of three months, renewable with the written consent of both parties.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Article Three – Financial Compensation:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Party One commits to pay an amount of 4,500 US dollars, to be paid as follows: First payment: 2,000 dollars upon signing the contract. Final payment: 2,500 dollars upon final delivery of the project.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Article Four – Rights and Obligations of the Parties:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Party Two is committed to delivering the project within the specified time and according to technical standards. Party One is committed to providing all necessary information and materials for design and development in a timely manner.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Article Five – Termination:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Either party may terminate the contract with written notice at least 15 days in advance, with payment of the financial dues to the other party according to the work completed.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Article Six – Governing Law:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This contract is subject to the laws and regulations of the Syrian Arab Republic, and any dispute shall be resolved amicably, and if that is not possible, it shall be referred to the Civil Court of Damascus.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Signatures:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Party One:', 'Ahmad Khaled Mustafa'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Signature:', '___________'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Date:', '15/08/2025'),
                  const SizedBox(height: 16),
                  _buildInfoRow('Party Two:', 'Al-Noor Modern Technologies – Representative: Samer Abdullah'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Signature:', '___________'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Date:', '15/08/2025'),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VerifyPinScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF37C293),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Sign the contract',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1D3D),
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithLink(String label, String email) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1D3D),
            height: 1.5,
          ),
        ),
        Expanded(
          child: Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3B82F6),
              height: 1.5,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}