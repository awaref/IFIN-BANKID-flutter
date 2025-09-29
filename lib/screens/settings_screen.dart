import 'package:flutter/material.dart';
import 'package:bankid_app/screens/delete_account_screen.dart';
import 'package:bankid_app/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // General Settings
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'General Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('App Fingerprint'),
            trailing: Switch(
              value: true, // This should be dynamic
              onChanged: (bool value) {
                // Handle switch change
              },
            ),
            onTap: () {
              // Navigate to App Fingerprint settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            onTap: () {
              // Navigate to Language selection
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help and Support'),
            onTap: () {
              // Navigate to Help and Support
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About the App'),
            onTap: () {
              // Navigate to About the App
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Use'),
            onTap: () {
              // Navigate to Terms of Use
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {
              // Navigate to Privacy Policy
            },
          ),

          // Account Settings
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Account Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            onTap: () {
              // Navigate to Change Password screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Transaction History'),
            onTap: () {
              // Navigate to Transaction History screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('ID Card'),
            subtitle: const Text(
              'Manage your personal identity. Learn more about how to do it.',
            ),
            onTap: () {
              // Navigate to ID Card management
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeleteAccountScreen(),
                ),
              );
            },
          ),

          // New Account
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('New', style: Theme.of(context).textTheme.titleLarge),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add New Account'),
            onTap: () {
              // Navigate to Add New Account screen
            },
          ),
        ],
      ),
    );
  }
}
