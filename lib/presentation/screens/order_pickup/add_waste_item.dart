// lib/app/presentation/screens/pickup/add_waste_item_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cemungut_app/app/models/waste_item.dart';

class AddWasteItemScreen extends StatefulWidget {
  const AddWasteItemScreen({super.key});

  @override
  State<AddWasteItemScreen> createState() => _AddWasteItemScreenState();
}

class _AddWasteItemScreenState extends State<AddWasteItemScreen> {
  // State untuk memilih gambar (ini tetap sama)
  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile;

  // State lain (tetap sama)
  int _quantity = 1;
  WasteCategory? _selectedCategory;
  final _notesController = TextEditingController();

  // Fungsi untuk memilih gambar (ini tetap sama)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Ambil Foto dari Kamera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNGSI INI JADI SANGAT SEDERHANA ---
  void _addItemToCart() {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih jenis sampah terlebih dahulu.')),
      );
      return;
    }

    // Tidak ada lagi upload! Langsung buat objeknya.
    final newItem = WasteItem(
      category: _selectedCategory!,
      quantity: _quantity,
      note: _notesController.text,
      imageFile: _selectedImageFile, // <-- Langsung masukkan File yang dipilih
    );

    // Kirim kembali item yang sudah berisi File gambar
    Navigator.pop(context, newItem);
  }

  // ... (fungsi increment/decrement dan dispose tetap sama) ...
  void _incrementQuantity() { setState(() => _quantity++); }
  void _decrementQuantity() { if (_quantity > 1) { setState(() => _quantity--); } }
  @override
  void dispose() { _notesController.dispose(); super.dispose(); }


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
            // Bagian Foto Sampah (UI tetap sama, logikanya yang berubah)
            const Text('Foto Sampah (Opsional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showImageSourceActionSheet,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: _selectedImageFile != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.file(_selectedImageFile!, fit: BoxFit.cover),
                )
                    : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Ketuk untuk menambah gambar'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sisa UI tidak ada yang berubah
            const Text('Jumlah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            // ... (Row dengan tombol +/-) ...
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
            const Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Deskripsikan sampah anda',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text('Jenis Sampah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            // ... (List radio button) ...
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
        // Tidak perlu loading state lagi
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