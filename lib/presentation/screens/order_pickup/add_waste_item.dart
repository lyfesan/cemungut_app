// lib/app/presentation/screens/pickup/add_waste_item_screen.dart

import 'package:flutter/material.dart';
import 'package:cemungut_app/app/models/waste_item.dart'; // Ganti dengan path yang benar

class AddWasteItemScreen extends StatefulWidget {
  const AddWasteItemScreen({super.key});

  @override
  State<AddWasteItemScreen> createState() => _AddWasteItemScreenState();
}

class _AddWasteItemScreenState extends State<AddWasteItemScreen> {
  int _quantity = 1;
  WasteCategory? _selectedCategory;
  final _notesController = TextEditingController();

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  void _addItemToCart() {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih jenis sampah terlebih dahulu.')),
      );
      return;
    }

    final newItem = WasteItem(
      category: _selectedCategory!,
      quantity: _quantity,
      note: _notesController.text,
    );
    Navigator.pop(context, newItem);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Sampah'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto Sampah (UI Placeholder)
            const Text('Foto Sampah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined, size: 30, color: Colors.grey),
                    SizedBox(width: 16),
                    Icon(Icons.camera_alt_outlined, size: 30, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Jumlah Sampah
            const Text('Jumlah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: _decrementQuantity, icon: const Icon(Icons.remove_circle_outline)),
                Text('$_quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(onPressed: _incrementQuantity, icon: const Icon(Icons.add_circle_outline)),
              ],
            ),
            const Center(child: Text('Berapa jumlah sampah?', style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 24),

            // Catatan
            const Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Deskripsikan sampah anda',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Jenis Sampah
            const Text('Jenis Sampah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...WasteCategory.values.map((category) {
              return Card(
                elevation: _selectedCategory == category ? 4 : 1,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: _selectedCategory == category ? const Color(0xFF1E824C) : Colors.grey.shade300,
                    width: _selectedCategory == category ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RadioListTile<WasteCategory>(
                  title: Text(category.displayName),
                  value: category,
                  groupValue: _selectedCategory,
                  onChanged: (WasteCategory? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  activeColor: const Color(0xFF1E824C),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _addItemToCart,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Tambah', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E824C),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}