// lib/app/presentation/screens/pickup/pickup_confirmation_screen.dart

import 'package:cemungut_app/app/models/pickup_order.dart';
import 'package:cemungut_app/app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cemungut_app/app/models/waste_item.dart';
import 'package:cemungut_app/app/services/firebase_auth_service.dart'; // Asumsi Anda punya service ini
import 'package:cemungut_app/app/models/app_user.dart'; // Untuk mendapatkan data user
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


class PickupConfirmationScreen extends StatefulWidget {
  final List<WasteItem> wasteItems;

  const PickupConfirmationScreen({super.key, required this.wasteItems});

  @override
  State<PickupConfirmationScreen> createState() => _PickupConfirmationScreenState();
}

class _PickupConfirmationScreenState extends State<PickupConfirmationScreen> {
  final _notesController = TextEditingController();
  DateTime? _selectedPickupDateTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

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

  // --- FUNGSI PICKER BARU ---
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedPickupDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      // Jika waktu belum dipilih, default ke jam sekarang
      final currentTime = TimeOfDay.fromDateTime(
          _selectedPickupDateTime ?? DateTime.now());
      setState(() {
        _selectedPickupDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          currentTime.hour,
          currentTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedPickupDateTime ?? DateTime.now()),
    );

    if (pickedTime != null) {
      // Jika tanggal belum dipilih, default ke hari ini
      final currentDate = _selectedPickupDateTime ?? DateTime.now();
      setState(() {
        _selectedPickupDateTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _processOrder() async {

    if (_selectedPickupDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih waktu penjemputan.')),
      );
      return;
    }

    setState(() => _isLoading = true);


    // 1. Dapatkan user yang sedang login
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus login untuk memesan.')));
      setState(() => _isLoading = false);
      return;
    }

    // 2. Dapatkan detail data user dari Firestore
    final appUser = await FirestoreService.getAppUser(currentUser.uid);
    if (appUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mendapatkan data pengguna.')));
      setState(() => _isLoading = false);
      return;
    }


    try {
      final totalItems =
      widget.wasteItems.fold<int>(0, (sum, item) => sum + item.quantity);
      final totalPoints = totalItems * 25;
      final orderId =
          FirebaseFirestore.instance.collection('pickupOrders').doc().id;

      final newOrder = PickupOrder(
        id: orderId,
        userId: currentUser.uid,
        userName: appUser.name,
        address: "Rumah Tung Tung Sahur", // Ganti dengan data alamat dari appUser
        items: widget.wasteItems,
        pickupTime: Timestamp.fromDate(_selectedPickupDateTime!), // <-- GUNAKAN STATE BARU
        status: PickupStatus.pending,
        estimatedPoints: totalPoints,
        orderNote: _notesController.text, // <-- TAMBAHKAN CATATAN DARI CONTROLLER
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await FirestoreService.createPickupOrder(newOrder);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permintaan penjemputan berhasil dibuat!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final summary = _getWasteSummary();
    final totalItems = summary.values.reduce((a, b) => a + b);
    final totalPoints = totalItems * 25;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Lokasi
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Color(0xFF1E824C)),
                title: const Text('Lokasi Penjemputan'),
                subtitle: const Text('Rumah Tung Tung Sahur'),
                trailing:
                TextButton(onPressed: () {}, child: const Text('Ubah')),
              ),
            ),
            const SizedBox(height: 16),

            // --- WAKTU JEMPUT (UI BARU) ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Waktu Jemput',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    // Tombol Pilih Tanggal
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: Colors.grey),
                      title: Text(_selectedPickupDateTime == null
                          ? 'Pilih Tanggal'
                          : DateFormat('EEEE, d MMMM y', 'id_ID').format(_selectedPickupDateTime!)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectDate,
                    ),
                    const Divider(),
                    // Tombol Pilih Waktu
                    ListTile(
                      leading: const Icon(Icons.access_time, color: Colors.grey),
                      title: Text(_selectedPickupDateTime == null
                          ? 'Pilih Waktu'
                          : DateFormat('HH:mm').format(_selectedPickupDateTime!)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectTime,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- CATATAN (UI BARU) ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan untuk Pengemudi (Opsional)',
                    hintText: 'Contoh: Titip di pos satpam, atau pagar warna hijau.',
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.note_alt_outlined),
                  ),
                  maxLines: 3,
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
                    const Text('Rincian Sampah',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    ...summary.entries.map((entry) {
                      if (entry.value == 0) return const SizedBox.shrink(); // Jangan tampilkan jika jumlahnya 0
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
                        const Text('Total',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('$totalItems',
                            style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estimasi Poin'),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text('$totalPoints',
                                style: const TextStyle(
                                    color: Color(0xFF1E824C),
                                    fontWeight: FontWeight.bold)),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton.icon(
          onPressed: _processOrder,
          icon: const Text('Pesan',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          label: const Icon(Icons.arrow_forward, color: Colors.white),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E824C),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}