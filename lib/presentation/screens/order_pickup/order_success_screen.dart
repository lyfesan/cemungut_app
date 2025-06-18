// lib/app/presentation/screens/pickup/order_success_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cemungut_app/presentation/screens/navigation_menu.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna yang sesuai dengan brand Anda
    const primaryColor = Color(0xFF4CAF50); // Hijau muda untuk container
    const darkGreenColor = Color(0xFF1E824C); // Hijau tua untuk tombol

    return Scaffold(
      // Kita buat AppBar sendiri agar bisa menghilangkan tombol kembali
      appBar: AppBar(
        // title: const Text('Terima Kasih'),
        centerTitle: true,
        title: Image.asset('assets/CemGo.png', height: 32),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        // Ini penting agar pengguna tidak bisa menekan tombol 'back' ke halaman konfirmasi
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container hijau utama
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Ganti dengan logo Anda jika ada, untuk sekarang kita pakai ikon
                  Image.asset(
                    'assets/icon/app_icon.png',
                    height: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CEMUNGUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.white.withOpacity(0.5)),
                  const SizedBox(height: 24),
                  const Text(
                    'Terima Kasih Telah Menggunakan Layanan Kami',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.white.withOpacity(0.5)),
                  const SizedBox(height: 24),
                  const Text(
                    'Pesanan Anda akan Kami Proses',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            const Spacer(), // Mendorong tombol ke bagian bawah

            // Tombol Daftar Transaksi
            OutlinedButton(
              onPressed: () {
                // Temukan controller navigasi
                print("AWAAAA");
                final navController = Get.find<NavigationController>();
                // Ubah index ke tab 'Transaksi' (index 2)
                navController.changeIndex(2);
                // Kembali ke halaman root (NavigationMenu)
                // Ini akan langsung menampilkan tab yang benar.
                Get.offAll(() => NavigationMenu());
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: darkGreenColor, width: 1.5),
                foregroundColor: darkGreenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Daftar Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),

            // Tombol Kembali ke Home
            ElevatedButton(
              onPressed: () {
                // Temukan controller navigasi
                print('koooo');
                final navController = Get.find<NavigationController>();
                // Ubah index ke tab 'Home' (index 0)
                navController.changeIndex(0);
                // Kembali ke halaman root
                Get.offAll(() => NavigationMenu());
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: darkGreenColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Kembali ke Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}