import 'package:flutter/material.dart';
import 'package:cemungut_app/app/services/firebase_auth_service.dart'; // Adjust path if needed

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showAboutAppDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Cemungut',
      applicationVersion: '1.0.0',
      applicationIcon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('assets/icon/app_icon.png', width: 48),
      ),
      // Updated copyright year
      applicationLegalese: '© 2025 Cemungut Team',
      children: const <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'Cemungut adalah aplikasi inovatif yang dirancang untuk memudahkan pengelolaan sampah Anda sambil memberikan edukasi dan imbalan.',
          ),
        )
      ],
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah anda yakin ingin keluar dari akun?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      await FirebaseAuthService.signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        // The Column no longer needs to push content to the bottom
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Alamat Tersimpan'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              onTap: (){},
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Tentang Aplikasi'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              onTap: () => _showAboutAppDialog(context),
            ),
            const Divider(),

            // --- UPDATED LOGOUT WIDGET ---
            // The button is replaced with this ListTile for a cleaner look
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Keluar Akun',
                style: TextStyle(color: Colors.red),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              onTap: () => _signOut(context),
            ),
            const Divider(),
            // --- END OF UPDATE ---
          ],
        ),
      ),
    );
  }
}