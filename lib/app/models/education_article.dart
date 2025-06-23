import 'package:cloud_firestore/cloud_firestore.dart';

class EducationArticle {
  final String id;
  final String title;
  final String content;
  final String imageUrl; // URL gambar dari Firebase Storage

  EducationArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
  });

  // Factory constructor untuk membuat objek EducationArticle dari dokumen Firestore
  factory EducationArticle.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EducationArticle(
      id: doc.id,
      title:
          data['title'] ?? 'Tanpa Judul', // Default value jika data tidak ada
      content: data['content'] ?? 'Konten tidak tersedia.',
      imageUrl: data['imageUrl'] ?? '', // Default value string kosong
    );
  }
}
