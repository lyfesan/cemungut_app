// lib/app/models/address.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  final String id;
  final String name; // e.g., "Rumah", "Kantor"
  final String addressDetail; // Full address string from geocoding
  final String? note; // e.g., "Pagar warna hijau"
  final GeoPoint location; // Coordinates

  Address({
    required this.id,
    required this.name,
    required this.addressDetail,
    this.note,
    required this.location,
  });

  // Factory constructor to create an Address from a Firestore document
  factory Address.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Address(
      id: doc.id,
      name: data['name'] ?? '',
      addressDetail: data['addressDetail'] ?? '',
      note: data['note'],
      location: data['location'] ?? const GeoPoint(0, 0),
    );
  }

  // Method to convert an Address instance to a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'addressDetail': addressDetail,
      'note': note,
      'location': location,
    };
  }
}