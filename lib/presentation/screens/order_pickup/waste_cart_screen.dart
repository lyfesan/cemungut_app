// lib/app/presentation/screens/pickup/waste_cart_screen.dart

import 'package:flutter/material.dart';
import 'package:cemungut_app/app/models/waste_item.dart';
import 'package:cemungut_app/presentation/screens/order_pickup/add_waste_item.dart';
import 'package:cemungut_app/presentation/screens/order_pickup/confirmation.dart';

class WasteCartScreen extends StatefulWidget {
  const WasteCartScreen({super.key});

  @override
  State<WasteCartScreen> createState() => _WasteCartScreenState();
}

class _WasteCartScreenState extends State<WasteCartScreen> {
  final List<WasteItem> _wasteItems = [];

  void _navigateToAddWasteItem() async {
    final result = await Navigator.push<WasteItem>(
      context,
      MaterialPageRoute(builder: (context) => const AddWasteItemScreen()),
    );

    if (result != null) {
      setState(() {
        // Logika ini tetap sama
        final index = _wasteItems.indexWhere((item) => item.category == result.category);
        if (index != -1) {
          _wasteItems[index].quantity += result.quantity;
        } else {
          _wasteItems.add(result);
        }
      });
    }
  }

  void _navigateToConfirmation() {
    // ... (Logika ini tetap sama)
    if (_wasteItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang sampah masih kosong.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickupConfirmationScreen(wasteItems: _wasteItems),
      ),
    );
  }

  void _deleteItem(int index) {
    setState(() {
      _wasteItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/CemGo.png', height: 32),
      ),
      body: _wasteItems.isEmpty
          ? const Center(
        // ... (Tampilan saat kosong tetap sama)
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _wasteItems.length,
        itemBuilder: (context, index) {
          final item = _wasteItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              // --- PERUBAHAN UTAMA DI SINI ---
              leading: SizedBox(
                width: 50,
                height: 50,
                child: item.imageFile != null
                // Jika ada gambar, tampilkan gambar dari file
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    item.imageFile!,
                    fit: BoxFit.cover,
                  ),
                )
                // Jika tidak ada, tampilkan ikon checkbox
                    : const Icon(Icons.check_box, color: Color(0xFF1E824C)),
              ),
              title: Text(
                item.category.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jumlah : ${item.quantity}'),
                  if (item.note != null && item.note!.isNotEmpty)
                    Text('Note : ${item.note}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteItem(index),
              ),
            ),
          );
        },
      ),
      // ... (FloatingActionButton dan BottomNavigationBar tetap sama)
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddWasteItem,
        backgroundColor: const Color(0xFF1E824C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _navigateToConfirmation,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E824C),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Pilih',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}