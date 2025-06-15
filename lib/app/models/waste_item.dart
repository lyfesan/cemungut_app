// lib/app/models/waste_item.dart

import 'package:flutter/material.dart';

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

  WasteItem({
    required this.category,
    this.quantity = 1,
    this.note,
  });
}