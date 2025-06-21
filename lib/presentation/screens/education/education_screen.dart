import 'package:cemungut_app/app/models/education_article.dart';
import 'package:cemungut_app/app/services/firestore_service.dart';
import 'package:cemungut_app/presentation/screens/education/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  // State untuk menampung hasil pengambilan data dari Firestore
  late Future<List<EducationArticle>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengambil data saat halaman pertama kali dibuka
    _articlesFuture = FirestoreService.getEducationArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar dengan logo seperti yang kita sepakati
        title: Image.asset('assets/CemEdu.png', height: 32),
        centerTitle: true,
        // Tombol kembali akan muncul secara otomatis oleh navigasi Flutter
      ),
      body: FutureBuilder<List<EducationArticle>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          // 1. Saat data sedang dimuat
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Jika terjadi error atau tidak ada data
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Gagal memuat artikel edukasi atau belum ada artikel tersedia.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            );
          }

          // 3. Jika data berhasil didapatkan
          final articles = snapshot.data!;
          return Stack(
            children: [
              // Daftar Kartu Edukasi yang bisa di-scroll
              ListView.builder(
                // Beri padding di bawah agar tidak tertutup tombol kuis
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  return _buildArticleCard(articles[index]);
                },
              ),

              // Tombol "Yuk, Ikut Kuis!" yang menempel di bawah
              _buildQuizButton(),
            ],
          );
        },
      ),
    );
  }

  // Widget untuk membangun setiap kartu artikel
  Widget _buildArticleCard(EducationArticle article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior:
          Clip.antiAlias, // Penting agar gambar mengikuti bentuk kartu
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Artikel
          Image.network(
            article.imageUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            // Tampilkan loading indicator saat gambar dimuat
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 180,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            // Tampilkan ikon error jika gambar gagal dimuat
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 180,
                color: Colors.grey[200],
                child: Icon(
                  Icons.broken_image,
                  color: Colors.grey[400],
                  size: 50,
                ),
              );
            },
          ),
          // Judul dan Konten Artikel
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  article.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk membangun tombol kuis di bagian bawah
  Widget _buildQuizButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        // Efek gradasi agar tidak menutupi konten secara kasar
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // Arahkan ke halaman kuis
            Get.to(() => const QuizScreen());
          },
          child: const Text(
            'Sudah Paham? Yuk, Ikut Kuis!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
