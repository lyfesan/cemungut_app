// Lokasi: lib/app/services/tflite_service.dart
// --- KODE DENGAN PERBAIKAN TIPE DATA TENSOR (uint8) ---

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteService {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    if (_interpreter != null) return;
    try {
      final labelsData = await rootBundle.loadString('assets/ml/labels.txt');
      _labels =
          labelsData
              .split('\n')
              .map((label) => label.trim())
              .where((label) => label.isNotEmpty)
              .toList();
      _interpreter = await Interpreter.fromAsset('assets/ml/model.tflite');
      print('--- LOG: Model dan label berhasil dimuat.');
    } catch (e) {
      print('--- ERROR: Gagal memuat model atau label: $e');
    }
  }

  Future<Map<String, dynamic>?> predictImage(String imagePath) async {
    await loadModel();
    if (_interpreter == null || _labels == null) {
      print('--- ERROR: Model atau label belum dimuat saat prediksi.');
      return null;
    }

    try {
      print('--- LOG 1: Membaca dan men-decode gambar...');
      final imageFile = File(imagePath);
      img.Image? originalImage = img.decodeImage(await imageFile.readAsBytes());
      if (originalImage == null) {
        print('--- ERROR: Gagal men-decode gambar.');
        return null;
      }
      print('--- LOG 2: Gambar berhasil di-decode. Mengubah ukuran...');

      final resizedImage = img.copyResize(
        originalImage,
        width: 224,
        height: 224,
      );
      print('--- LOG 3: Ukuran gambar berhasil diubah. Memproses tensor...');

      // --- PERBAIKAN 1: GUNAKAN Uint8List BUKAN Float32List ---
      var inputTensor = Uint8List(1 * 224 * 224 * 3);
      var bufferIndex = 0;
      for (var y = 0; y < resizedImage.height; y++) {
        for (var x = 0; x < resizedImage.width; x++) {
          var pixel = resizedImage.getPixel(x, y);
          // --- PERBAIKAN 2: HAPUS NORMALISASI, GUNAKAN NILAI ASLI 0-255 ---
          inputTensor[bufferIndex++] = pixel.r.toInt();
          inputTensor[bufferIndex++] = pixel.g.toInt();
          inputTensor[bufferIndex++] = pixel.b.toInt();
        }
      }
      final input = inputTensor.reshape([1, 224, 224, 3]);
      print('--- LOG 4: Tensor siap. Menjalankan inferensi model...');

      // --- PERBAIKAN 3: SIAPKAN OUTPUT UNTUK MENERIMA uint8 ---
      final output = List.filled(
        1 * _labels!.length,
        0,
      ).reshape([1, _labels!.length]);

      _interpreter!.run(input, output);
      print('--- LOG 5: Inferensi model selesai. Memproses hasil...');

      final result = output[0] as List<int>;
      int maxIndex = 0;
      int maxValue = -1;
      for (int i = 0; i < result.length; i++) {
        if (result[i] > maxValue) {
          maxValue = result[i];
          maxIndex = i;
        }
      }
      print('--- LOG 6: Hasil ditemukan: ${_labels![maxIndex]}');

      // --- PERBAIKAN 4: HITUNG SKOR KEYAKINAN DENGAN MEMBAGI 255 ---
      final confidence = maxValue / 255.0;

      return {'label': _labels![maxIndex], 'confidence': confidence};
    } catch (e) {
      print('--- ERROR saat prediksi: $e');
      return null;
    }
  }

  void dispose() {
    _interpreter?.close();
    print('--- LOG: Interpreter ditutup.');
  }
}
