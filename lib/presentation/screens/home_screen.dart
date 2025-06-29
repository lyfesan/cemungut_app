import 'package:cemungut_app/presentation/screens/detection/detection_screen.dart';
import 'package:cemungut_app/presentation/screens/education/education_screen.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:cemungut_app/presentation/screens/profile/profile_screen.dart';
import 'package:get/get.dart';
import 'package:cemungut_app/presentation/screens/navigation_menu.dart'; // Adjust path
import '../../app/models/app_user.dart';
import '../../app/services/firebase_auth_service.dart';
import '../../app/services/firestore_service.dart';
import 'bank_sampah/bank_sampah_screen.dart';
import 'package:cemungut_app/presentation/screens/order_pickup/waste_cart_screen.dart';
import 'package:cemungut_app/app/models/address.dart';
import 'package:cemungut_app/presentation/screens/order_pickup/select_address_screen.dart';

class HomeScreen extends StatefulWidget {
  // 1. Accept the new keys
  final GlobalKey orderCardKey;
  final GlobalKey pointsCardKey;
  final GlobalKey detectionKey;
  final GlobalKey educationKey;
  final GlobalKey bankSampahKey;

  const HomeScreen({
    super.key,
    required this.orderCardKey,
    required this.pointsCardKey,
    required this.detectionKey,
    required this.educationKey,
    required this.bankSampahKey,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NavigationController navController = Get.find();
  Address? _selectedAddress;
  bool _isAddressLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchInitialAddress(); // <-- PANGGIL FUNGSI UNTUK AMBIL ALAMAT
  }

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

  // Di dalam class _HomeScreenState

// --- FUNGSI BARU UNTUK MENGAMBIL ALAMAT AWAL ---
  Future<void> _fetchInitialAddress() async {
    // Pastikan widget masih ada di tree sebelum set state
    if (!mounted) return;

    setState(() {
      _isAddressLoading = true;
    });

    final userId = FirebaseAuthService.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        setState(() => _isAddressLoading = false);
      }
      return;
    }

    final firstAddress = await FirestoreService.getFirstAddress(userId);
    if (mounted) {
      setState(() {
        _selectedAddress = firstAddress;
        _isAddressLoading = false;
      });
    }
  }

// --- FUNGSI BARU UNTUK NAVIGASI KE PILIH ALAMAT ---
  Future<void> _changeAddress() async {
    final result = await Navigator.of(context).push<Address>(
      MaterialPageRoute(builder: (context) => const SelectAddressScreen()),
    );

    // Jika user memilih alamat dari layar `SelectAddressScreen`
    if (result != null && mounted) {
      setState(() {
        _selectedAddress = result;
      });
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
    // ... main build method remains the same ...
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
            Showcase(
              key: widget.orderCardKey,
              title: 'Pesan Penjemputan',
              description: 'Tekan di sini untuk memesan jadwal penjemputan sampah Anda.',
              // Add styling here
              // tooltipBackgroundColor: Theme.of(context).primaryColor,
              // textColor: Colors.white,
              // tooltipPadding: const EdgeInsets.all(12.0),
              // tooltipBorderRadius: BorderRadius.circular(16),
              child: _buildOrderNowCard(context),
            ),
            const SizedBox(height: 24),
            _buildFeatureShortcuts(context),
            const SizedBox(height: 24),
            Showcase(
              key: widget.pointsCardKey,
              title: 'CemPoin Anda',
              description: 'Pantau perolehan poin Anda di sini. Semakin banyak sampah, semakin banyak poin!',
              // Add styling here
              // tooltipBackgroundColor: Theme.of(context).primaryColor,
              // textColor: Colors.white,
              // tooltipPadding: const EdgeInsets.all(12.0),
              // tooltipBorderRadius: BorderRadius.circular(16),
              child: _buildPointsCard(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // ... This method remains the same ...
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
                      fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildLocationCard(BuildContext context) {
    Widget content;

    if (_isAddressLoading) {
      // --- TAMPILAN SAAT LOADING ---
      content = const Row(
        children: [
          CircularProgressIndicator(strokeWidth: 2),
          SizedBox(width: 16),
          Text('Memuat alamat...'),
        ],
      );
    } else if (_selectedAddress == null) {
      // --- TAMPILAN JIKA TIDAK ADA ALAMAT TERSIMPAN ---
      content = Row(
        children: [
          Icon(Icons.add_location_alt_outlined,
              color: Theme.of(context).primaryColor, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lokasi penjemputan', style: TextStyle(color: Colors.grey)),
                Text('Pilih atau tambah alamat',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
        ],
      );
    } else {
      // --- TAMPILAN JIKA ALAMAT SUDAH ADA ---
      content = Row(
        children: [
          Icon(Icons.location_on,
              color: Theme.of(context).primaryColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedAddress!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  _selectedAddress!.addressDetail,
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      );
    }

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _changeAddress, // <-- PANGGIL FUNGSI UBAH ALAMAT
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: content,
        ),
      ),
    );
  }

  Widget _buildOrderNowCard(BuildContext context) {
    // ... This method remains the same ...
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
              Icon(Icons.delete_outline, color: Colors.white, size: 48),
              SizedBox(height: 8),
              Text('Pesan Penjemputan Sampah',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // --- THIS METHOD IS UPDATED ---
  Widget _buildFeatureShortcuts(BuildContext context) {
    return Row(
      children: [
        // 2a. Wrap each shortcut card in a Showcase widget
        // The _buildShortcutCard already returns an Expanded, so we wrap that call.
        _buildShortcutCard(
          context,
          key: widget.detectionKey,
          icon: Icons.document_scanner_outlined,
          label: 'Deteksi Sampah',
          showcaseTitle: 'Deteksi Sampah',
          showcaseDesc: 'Gunakan AI untuk mendeteksi jenis sampah dari gambar.',
          onTap: () {
            //Get.to(DetectionScreen())
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => const DetectionScreen())
            );
          },
        ),
        const SizedBox(width: 12),
        _buildShortcutCard(
          context,
          key: widget.educationKey,
          icon: Icons.school_outlined,
          label: 'Edukasi Sampah',
          showcaseTitle: 'Edukasi Sampah',
          showcaseDesc: 'Pelajari lebih lanjut tentang pengelolaan sampah yang benar.',
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const EducationScreen())
            );
          },
        ),
        const SizedBox(width: 12),
        _buildShortcutCard(
          context,
          key: widget.bankSampahKey,
          icon: Icons.store_mall_directory_outlined,
          label: 'Lokasi Bank Sampah',
          showcaseTitle: 'Lokasi Bank Sampah',
          showcaseDesc: 'Temukan lokasi bank sampah terdekat di sekitar Anda.',
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

  // 2b. Update the helper method to accept the key and showcase details
  Widget _buildShortcutCard(
      BuildContext context, {
        required GlobalKey key,
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        required String showcaseTitle,
        required String showcaseDesc,
      }) {
    return Expanded(
      child: Showcase(
        key: key,
        title: showcaseTitle,
        description: showcaseDesc,
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
                  Text(label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context) {
    final user = FirebaseAuthService.currentUser;
    if (user == null) return const SizedBox.shrink(); // Jangan tampilkan jika belum login

    return FutureBuilder<AppUser?>(
      future: FirestoreService.getAppUser(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator())),
          );
        }

        final appUser = snapshot.data!;
        const int goalPoints = 350;

        // Widget untuk bagian atas kartu (poin, progress, dll)
        Widget topContent;
        // Widget untuk bagian bawah kartu (bonus)
        Widget bottomContent;

        if (appUser.isGoldMember) {
          // --- TAMPILAN JIKA SUDAH GOLD MEMBER ---
          topContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield, color: Colors.amber[700], size: 28),
                  const SizedBox(width: 8),
                  Text('Anda adalah Gold Member!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Total Poin Anda Saat Ini: ${appUser.points}', style: const TextStyle(color: Colors.grey)),
            ],
          );
          bottomContent = Text('Bonus 3% poin di setiap transaksi!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold));
        } else {
          // --- TAMPILAN JIKA BELUM GOLD MEMBER ---
          final pointsToGoal = (goalPoints - appUser.points).clamp(0, goalPoints);
          final double progress = (appUser.points / goalPoints).clamp(0.0, 1.0);
          topContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$pointsToGoal CemPoin menuju Gold',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                color: Theme.of(context).primaryColor,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 4),
              Text('${appUser.points} / $goalPoints', style: const TextStyle(color: Colors.grey)),
            ],
          );
          bottomContent = Text('Dapatkan bonus setelah menjadi Gold Member',
              style: Theme.of(context).textTheme.bodyMedium);
        }

        return Card(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                topContent,
                const Divider(height: 24),
                const Text('Bonus untuk anda:'),
                bottomContent,
              ],
            ),
          ),
        );
      },
    );
  }
}