// lib/app/presentation/screens/pickup/pickup_confirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:cemungut_app/app/models/waste_item.dart'; // Ganti dengan path yang benar

class PickupConfirmationScreen extends StatefulWidget {
  final List<WasteItem> wasteItems;

  const PickupConfirmationScreen({super.key, required this.wasteItems});

  @override
  State<PickupConfirmationScreen> createState() => _PickupConfirmationScreenState();
}

class _PickupConfirmationScreenState extends State<PickupConfirmationScreen> {
  String _selectedDay = 'Hari Ini';
  String _selectedTime = 'Sekarang';

  // Fungsi untuk meringkas item sampah
  Map<WasteCategory, int> _getWasteSummary() {
    final Map<WasteCategory, int> summary = {};
    for (var category in WasteCategory.values) {
      summary[category] = 0; // Inisialisasi semua kategori dengan 0
    }
    for (var item in widget.wasteItems) {
      summary[item.category] = (summary[item.category] ?? 0) + item.quantity;
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    final summary = _getWasteSummary();
    final totalItems = summary.values.reduce((a, b) => a + b);
    final totalPoints = totalItems * 25; // Asumsi 1 item = 25 poin

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Penjemputan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Lokasi
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Color(0xFF1E824C)),
                title: const Text('Lokasi Penjemputan'),
                subtitle: const Text('Rumah Tung Tung Sahur'), // Ganti dengan data user
                trailing: TextButton(onPressed: () {}, child: const Text('Ubah alamat')),
              ),
            ),
            const SizedBox(height: 16),

            // Waktu Jemput
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Waktu Jemput', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Hari Ini'),
                            selected: _selectedDay == 'Hari Ini',
                            onSelected: (selected) {
                              setState(() => _selectedDay = 'Hari Ini');
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Besok'),
                            selected: _selectedDay == 'Besok',
                            onSelected: (selected) {
                              setState(() => _selectedDay = 'Besok');
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Sekarang'),
                            selected: _selectedTime == 'Sekarang',
                            onSelected: (selected) {
                              setState(() => _selectedTime = 'Sekarang');
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('09:00-10:00'),
                            selected: _selectedTime == '09:00-10:00',
                            onSelected: (selected) {
                              setState(() => _selectedTime = '09:00-10:00');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Jenis Sampah
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Jenis Sampah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    ...summary.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key.displayName),
                            Text('x${entry.value}'),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('$totalItems', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estimasi Poin'),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text('$totalPoints', style: const TextStyle(color: Color(0xFF1E824C), fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: Tambahkan logika untuk mengirim pesanan ke backend
            print('Pesanan dikirim!');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permintaan penjemputan berhasil dibuat!')),
            );
            // Kembali ke halaman home (root) setelah memesan
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          icon: const Text('Pesan', style: TextStyle(color: Colors.white, fontSize: 18)),
          label: const Icon(Icons.arrow_forward, color: Colors.white),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E824C),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}