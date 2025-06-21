// Lokasi: lib/presentation/screens/detection/detection_screen.dart

import 'dart:io';
import 'package:cemungut_app/presentation/screens/detection/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DetectionScreen extends StatelessWidget {
  const DetectionScreen({super.key});

  /// Fungsi untuk memilih gambar dan langsung bernavigasi ke halaman hasil.
  void _pickImageAndNavigate(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      // Jika gambar berhasil dipilih, kirim path gambar ke halaman hasil
      // untuk diproses dan ditampilkan.
      Get.to(() => ResultScreen(imagePath: pickedFile.path));
    } else {
      // Pengguna membatalkan pemilihan gambar.
      print('Pemilihan gambar dibatalkan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deteksi Sampah AI'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.document_scanner_outlined,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Deteksi Jenis Sampah',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Ambil foto atau pilih gambar dari galeri untuk dianalisis oleh AI kami.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Ambil Foto dari Kamera'),
              onPressed: () => _pickImageAndNavigate(ImageSource.camera),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: const Icon(Icons.photo_library),
              label: const Text('Pilih dari Galeri'),
              onPressed: () => _pickImageAndNavigate(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
