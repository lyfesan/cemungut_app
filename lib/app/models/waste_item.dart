// lib/app/models/waste_item.dart

import 'dart:io';


// Enum untuk kategori sampah agar lebih terstruktur
enum WasteCategory {
  plastik,
  kertasKardus,
  elektronik,
  kaca,
  rumahTangga,
  lainnya,
}

// Helper extension untuk mendapatkan nama yang bisa ditampilkan di UI
extension WasteCategoryExtension on WasteCategory {
  String get displayName {
    switch (this) {
      case WasteCategory.plastik:
        return 'Plastik';
      case WasteCategory.kertasKardus:
        return 'Kertas & Kardus';
      case WasteCategory.elektronik:
        return 'Elektronik';
      case WasteCategory.kaca:
        return 'Kaca';
      case WasteCategory.rumahTangga:
        return 'Rumah Tangga';
      case WasteCategory.lainnya:
        return 'Lainnya';
    }
  }
}

class WasteItem {
  final WasteCategory category;
  int quantity;
  final String? note;
  final File? imageFile;

  WasteItem({
    required this.category,
    this.quantity = 1,
    this.note,
    this.imageFile,
  });
  String get displayName => category.displayName;
  // BARU: Konversi WasteItem menjadi Map (untuk disimpan ke Firestore)
  Map<String, dynamic> toJson() {
    return {
      'category': category.name, // Simpan nama enum sebagai String
      'quantity': quantity,
      'note': note,
    };
  }

  // BARU: Buat WasteItem dari Map (saat membaca dari Firestore)
  factory WasteItem.fromMap(Map<String, dynamic> map) {
    return WasteItem(
      // Temukan enum dari string, default ke 'lainnya' jika tidak ketemu
      category: WasteCategory.values.firstWhere(
            (e) => e.name == map['category'],
        orElse: () => WasteCategory.lainnya,
      ),
      quantity: map['quantity'] ?? 1,
      note: map['note'],
    );
  }
}