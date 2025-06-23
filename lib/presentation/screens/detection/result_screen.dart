import 'dart:async';
import 'dart:io';
import 'package:cemungut_app/app/services/tflite_service.dart';
import 'package:cemungut_app/presentation/screens/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;

  const ResultScreen({super.key, required this.imagePath});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late TfliteService _tfliteService;
  Map<String, dynamic>? _prediction;
  bool _isLoading = true;
  String? _errorMessage;

  final Map<String, String> _labelTranslations = {
    'Cardboard': 'Kardus',
    'Food Organics': 'Sampah Makanan',
    'Glass': 'Kaca',
    'Metal': 'Logam',
    'Miscellaneous Trash': 'Sampah Lain-lain',
    'Paper': 'Kertas',
    'Plastic': 'Plastik',
    'Textile Trash': 'Sampah Tekstil',
    'Vegetation': 'Tumbuhan/Sayuran',
  };
  final Map<String, Map<String, dynamic>> _categoryInfo = {
    'Cardboard': {'category': 'Anorganik', 'icon': Icons.inventory_2_outlined},
    'Food Organics': {'category': 'Organik', 'icon': Icons.restaurant_outlined},
    'Glass': {'category': 'Anorganik', 'icon': Icons.wine_bar_outlined},
    'Metal': {'category': 'Anorganik', 'icon': Icons.build_outlined},
    'Miscellaneous Trash': {
      'category': 'Residu',
      'icon': Icons.delete_sweep_outlined,
    },
    'Paper': {'category': 'Anorganik', 'icon': Icons.description_outlined},
    'Plastic': {'category': 'Anorganik', 'icon': Icons.opacity_outlined},
    'Textile Trash': {
      'category': 'Anorganik',
      'icon': Icons.checkroom_outlined,
    },
    'Vegetation': {'category': 'Organik', 'icon': Icons.eco_outlined},
  };
  final Map<String, String> _recommendations = {
    'Cardboard':
        'Pipihkan kardus untuk menghemat ruang. Pastikan dalam keadaan kering dan bersih sebelum disetorkan ke bank sampah.',
    'Food Organics':
        'Sampah ini sangat baik untuk diolah menjadi kompos. Jangan dicampur dengan sampah anorganik agar proses pembusukan sempurna.',
    'Glass':
        'Hati-hati dengan pecahan kaca. Kumpulkan secara terpisah dan berikan label "pecahan kaca" agar petugas kebersihan lebih waspada.',
    'Metal':
        'Kaleng minuman atau makanan sebaiknya dibersihkan terlebih dahulu sebelum disetorkan. Logam memiliki nilai jual yang tinggi untuk didaur ulang.',
    'Miscellaneous Trash':
        'Ini adalah sampah residu yang sulit didaur ulang. Usahakan untuk mengurangi penggunaannya. Buang pada tempatnya.',
    'Paper':
        'Pastikan kertas tidak basah atau tercampur minyak. Kertas adalah salah satu bahan yang paling mudah untuk didaur ulang.',
    'Plastic':
        'Bersihkan sisa makanan atau minuman dari kemasan plastik. Beberapa jenis plastik memiliki kode daur ulang yang berbeda.',
    'Textile Trash':
        'Pakaian atau kain bekas yang masih layak pakai dapat disumbangkan. Jika sudah tidak layak, bisa dijadikan lap pembersih.',
    'Vegetation':
        'Sama seperti sampah makanan, sisa sayuran dan daun kering sangat ideal untuk dijadikan bahan utama pembuatan pupuk kompos.',
  };

  @override
  void initState() {
    super.initState();
    _tfliteService = TfliteService();
    _runInferenceWithTimeout();
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }

  Future<void> _runInferenceWithTimeout() async {
    try {
      final result = await _tfliteService
          .predictImage(widget.imagePath)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw TimeoutException('Waktu analisis gambar habis.');
            },
          );

      if (mounted) {
        setState(() {
          _prediction = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Catch error (termasuk timeout) dan siapkan pesan
          _errorMessage =
              e is TimeoutException
                  ? 'Waktu analisis habis. Coba lagi dengan gambar lain.'
                  : 'Gagal melakukan deteksi. Pastikan gambar jelas.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/Hasil_Deteksi.png', height: 32),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body:
          _isLoading
              ? _buildLoadingView()
              : _errorMessage != null
              ? _buildErrorView(_errorMessage!)
              : _prediction == null
              ? _buildErrorView('Terjadi kesalahan tidak diketahui.')
              : _buildResultView(),
    );
  }

  Widget _buildLoadingView() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Menganalisis gambar...'),
      ],
    ),
  );

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final String englishLabel = _prediction!['label'];
    final double confidence = _prediction!['confidence'];

    final String translatedLabel =
        _labelTranslations[englishLabel] ?? 'Tidak Dikenali';
    final String category =
        _categoryInfo[englishLabel]?['category'] ?? 'Lainnya';
    final IconData icon =
        _categoryInfo[englishLabel]?['icon'] ?? Icons.help_outline;
    final String recommendation =
        _recommendations[englishLabel] ??
        'Tidak ada rekomendasi untuk sampah jenis ini.';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(widget.imagePath),
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          Icon(icon, size: 60, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(
            translatedLabel,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            '($category)',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tingkat Keyakinan: ${(confidence * 100).toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Rekomendasi Penanganan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 20),
                  Text(
                    recommendation,
                    style: TextStyle(height: 1.5, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Deteksi Ulang'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Get.offAll(() => NavigationMenu()),
                  child: const Text('Selesai'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
