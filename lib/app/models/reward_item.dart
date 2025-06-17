// lib/app/models/reward_item.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Enum untuk kategori reward agar lebih aman dan mudah difilter
enum RewardCategory {
  semua, // Ini untuk filter di UI, bukan di data
  saldo,
  voucher,
  kupon,
}

class RewardItem {
  final String id;
  final String name;
  final int pointsRequired;
  final RewardCategory category;
  final String imageUrl; // URL untuk logo seperti 'gopay'

  RewardItem({
    required this.id,
    required this.name,
    required this.pointsRequired,
    required this.category,
    required this.imageUrl,
  });

  String get localAssetPath {
    final lowerCaseName = name.toLowerCase();
    if (lowerCaseName.contains('gopay') || lowerCaseName.contains('gojek')) {
      return 'assets/gopay.png';
    }
    // Jika ada brand lain, tambahkan kondisinya di sini
    if (lowerCaseName.contains('hypermart')) {
      return 'assets/hypermart.png';
    }

    if (lowerCaseName.contains('shopeefood')) {
      return 'assets/shopee.png';
    }
    return ''; // Kembalikan string kosong jika tidak ada yang cocok
  }

  factory RewardItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return RewardItem(
      id: doc.id,
      name: data['name'] ?? 'Tanpa Nama',
      pointsRequired: data['pointsRequired'] ?? 9999,
      // Ubah string dari DB menjadi enum
      category: RewardCategory.values.firstWhere(
            (e) => e.name == data['category'],
        orElse: () => RewardCategory.voucher, // Default jika kategori salah
      ),
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}