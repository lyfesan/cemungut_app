import 'package:cemungut_app/presentation/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cemungut_app/presentation/screens/navigation_menu.dart'; // Adjust path
import '../../app/models/app_user.dart';
import '../../app/services/firebase_auth_service.dart';
import '../../app/services/firestore_service.dart';
import 'bank_sampah/bank_sampah_screen.dart';
import 'package:cemungut_app/presentation/screens/order_pickup/waste_cart_screen.dart';
import 'package:cemungut_app/presentation/screens/detection/detection_screen.dart'; // <-- 1. TAMBAHKAN IMPORT INI

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NavigationController navController = Get.find();

  Future<void> _signOut() async {
    // ... (sign out logic remains the same)
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah anda yakin ingin logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await FirebaseAuthService.signOut();
    }
  }

  Future<String?> fetchUserName() async {
    // ... (fetch user name logic remains the same)
    final user = FirebaseAuthService.currentUser;
    if (user == null) return null;
    try {
      final AppUser? appUser = await FirestoreService.getAppUser(user.uid);
      return appUser?.name;
    } catch (e) {
      print("Error fetching user name: $e");
      return "User";
    }
  }

  @override
  Widget build(BuildContext context) {
    // HomeScreen no longer has a Scaffold. It's just the body content.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- NEW HEADER WIDGET IN THE BODY ---
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildLocationCard(context),
            const SizedBox(height: 16),
            _buildOrderNowCard(context),
            const SizedBox(height: 24),
            _buildFeatureShortcuts(context),
            const SizedBox(height: 24),
            _buildPointsCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // This helper builds the new header that sits at the top of the body
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: const Icon(Icons.person, size: 28),
          ),
        ),
        const SizedBox(width: 12),
        FutureBuilder<String?>(
          future: fetchUserName(),
          builder: (context, snapshot) {
            String name = snapshot.data ?? 'Munguters';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat datang,',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
        const Spacer(), // Pushes the logout button to the end
        IconButton(
          onPressed: _signOut,
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Logout',
        ),
      ],
    );
  }

  // All other _build...Card methods remain the same as before.
  Widget _buildLocationCard(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Theme.of(context).primaryColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi penjemputan',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  'Rumah Tung Tung Sahur',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            const Text('Ubah alamat', style: TextStyle(color: Colors.grey)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderNowCard(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WasteCartScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            children: [
              Icon(Icons.redeem_rounded, color: Colors.white, size: 48),
              SizedBox(height: 8),
              Text(
                'Pesan Penjemputan Sampah',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureShortcuts(BuildContext context) {
    return Row(
      children: [
        _buildShortcutCard(
          context,
          icon: Icons.document_scanner_outlined,
          label: 'Deteksi Sampah',
          onTap: () {
            Get.to(() => const DetectionScreen());
          },
        ),
        const SizedBox(width: 12),
        _buildShortcutCard(
          context,
          icon: Icons.school_outlined,
          label: 'Edukasi Sampah',
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _buildShortcutCard(
          context,
          icon: Icons.store_mall_directory_outlined,
          label: 'Lokasi Bank Sampah',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BankSampahScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildShortcutCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 36),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: FirestoreService.getAppUser(FirebaseAuthService.currentUser!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Tampilkan placeholder saat loading
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final user = snapshot.data!;
        const int goalPoints = 350;
        final double progress = (user.points / goalPoints).clamp(0.0, 1.0);

        return Card(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${goalPoints - user.points} CemPoin menuju Gold',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  color: Theme.of(context).primaryColor,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.points} / $goalPoints',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Divider(height: 24),
                const Text('Bonus untuk anda:'),
                Text(
                  '3% Ekstra poin saat berhasil order',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
