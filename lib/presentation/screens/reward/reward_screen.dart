// lib/app/presentation/screens/reward/reward_screen.dart

import 'package:flutter/material.dart';
import 'package:cemungut_app/app/models/app_user.dart';
import 'package:cemungut_app/app/models/reward_item.dart';
import 'package:cemungut_app/app/services/firestore_service.dart';
import 'package:cemungut_app/app/services/firebase_auth_service.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  Future<List<dynamic>>? _dataFuture;
  List<RewardItem> _allRewards = [];
  List<RewardItem> _filteredRewards = [];
  RewardCategory _selectedFilter = RewardCategory.semua;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final user = FirebaseAuthService.currentUser;
    if (user == null) {
      // Jika user tidak login, jangan lakukan apa-apa
      setState(() {
        _dataFuture = Future.value([]); // Selesaikan future dengan data kosong
      });
      return;
    }

    // Ambil data user dan data reward secara bersamaan
    final future = Future.wait([
      FirestoreService.getAppUser(user.uid),
      FirestoreService.getRewards(),
    ]);

    // Setelah future selesai, BARU kita proses datanya dan panggil setState
    future.then((data) {
      if (mounted) { // Pastikan widget masih ada di tree
        setState(() {
          // data[0] adalah AppUser, data[1] adalah List<RewardItem>
          _allRewards = data[1] as List<RewardItem>;
          // Langsung panggil filter di sini, ini tempat yang aman!
          _filterRewards(_selectedFilter);
        });
      }
    }).catchError((error) {
      // Handle error jika terjadi
      print("Error in _loadData: $error");
    });

    // Set state future agar UI bisa menampilkan loading indicator
    setState(() {
      _dataFuture = future;
    });
  }

  Future<void> _showResultDialog(bool success, {String? message}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User harus menekan tombol
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(success ? 'Penukaran Berhasil' : 'Penukaran Gagal'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message ?? (success
                    ? 'Selamat! Hadiah akan segera kami proses.'
                    : 'Terjadi kesalahan.')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleRedeem(RewardItem reward, AppUser? currentUser) async {
    if (currentUser == null) return;

    // 1. Tampilkan dialog konfirmasi
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penukaran'),
        content: Text('Anda akan menukar ${reward.pointsRequired} poin dengan "${reward.name}". Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Tukar')),
        ],
      ),
    );

    // 2. Jika user tidak konfirmasi, hentikan proses
    if (confirmed != true) return;

    // 3. Cek apakah poin cukup
    if (currentUser.points < reward.pointsRequired) {
      await _showResultDialog(false, message: 'Poin Anda tidak cukup untuk menukar hadiah ini.');
      return;
    }

    // 4. Proses penukaran
    setState(() => _isLoading = true);
    try {
      await FirestoreService.redeemPoints(
        userId: currentUser.id,
        pointsToDeduct: reward.pointsRequired,
      );
      // Jika berhasil, tampilkan dialog sukses
      await _showResultDialog(true);
      // Muat ulang data untuk memperbarui jumlah poin di UI
      _loadData();

    } catch (e) {
      // Jika gagal, tampilkan dialog error
      await _showResultDialog(false, message: 'Terjadi kesalahan saat memproses permintaan Anda.');
    } finally {
      // Selalu hentikan loading state
      setState(() => _isLoading = false);
    }
  }

  void _filterRewards(RewardCategory category) {
    setState(() {
      _selectedFilter = category;
      if (category == RewardCategory.semua) {
        _filteredRewards = _allRewards;
      } else {
        _filteredRewards = _allRewards.where((reward) => reward.category == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            'Hadiah',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary
            )
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      // --- FUTUREBUILDER INI JADI LEBIH SEDERHANA DAN AMAN ---
      body: Stack(
        children: [
          FutureBuilder<List<dynamic>>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('Tidak ada data.'));
              }

              final AppUser? appUser = snapshot.data![0];

              // Tidak ada lagi setState di sini!
              // Kita langsung bangun UI dengan data yang sudah diproses.
              return Column(
                children: [
                  _buildPointsHeader(appUser),
                  _buildFilterChips(),
                  Expanded(
                    child: _buildRewardList(appUser),
                  ),
                ],
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ]
      )
    );
  }

  Widget _buildPointsHeader(AppUser? user) {

    if (user == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Login untuk melihat poin dan hadiah.'),
          ),
        ),
      );
    }
    const int goalPoints = 350; // Definisikan goal point
    final theme = Theme.of(context);
    Widget topContent;
    // Widget untuk bagian bawah kartu (bonus)
    Widget bottomContent;
    if (user.isGoldMember) {
      // --- TAMPILAN JIKA SUDAH GOLD MEMBER ---
      topContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: Colors.amber[700], size: 28),
              const SizedBox(width: 8),
              Text('Anda adalah Gold Member!',
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                radius: 16,
                child: Image.asset(
                  'assets/Coin.png', // Sesuaikan path asset
                  height: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text('Total Poin Anda: ${user.points}',
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      );
      bottomContent = Text('Nikmati bonus 3% poin di setiap transaksi!',
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white));

    } else {
      // --- TAMPILAN JIKA BELUM GOLD MEMBER ---
      final pointsToGoal = (goalPoints - user.points).clamp(0, goalPoints);
      final double progress = (user.points / goalPoints).clamp(0.0, 1.0);
      topContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$pointsToGoal CemPoin menuju Gold',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
              Text('${user.points} / $goalPoints',
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            color: Colors.white,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      );
      bottomContent = Text('Dapatkan bonus setelah menjadi Gold Member',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: theme.colorScheme.primary, // Gunakan warna primer tema
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              topContent,
              const Divider(height: 24, color: Colors.white30),
              const Text('Keuntungan Anda:',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              bottomContent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        children: RewardCategory.values.map((category) {
          return ChoiceChip(
            label: Text(category.name[0].toUpperCase() + category.name.substring(1)),
            selected: _selectedFilter == category,
            onSelected: (isSelected) {
              if (isSelected) {
                _filterRewards(category);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRewardImage(RewardItem reward) {
    // Jika reward ini adalah aset lokal
    return Image.asset(
      reward.localAssetPath,
      fit: BoxFit.contain,
    );
  }

  Widget _buildRewardList(AppUser? user) {
    if (_filteredRewards.isEmpty) {
      return const Center(child: Text('Tidak ada reward di kategori ini.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredRewards.length,
      itemBuilder: (context, index) {
        final reward = _filteredRewards[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              _handleRedeem(reward, user);
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Gunakan helper method yang baru kita buat
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF), // Warna 'gopay'
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildRewardImage(reward),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(reward.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(children: [

                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ${reward.pointsRequired}',
                            style: const TextStyle(fontWeight: FontWeight.bold))
                      ])
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}