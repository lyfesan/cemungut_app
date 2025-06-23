// lib/app/models/pickup_order.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cemungut_app/app/models/waste_item.dart'; // Sesuaikan path

// Enum untuk status pesanan
enum PickupStatus {
  pending,
  confirmed,
  in_progress,
  completed,
  cancelled,
}

class PickupOrder {
  final String id;
  final String userId;
  final String userName; // Untuk kemudahan display
  final String address;
  final GeoPoint pickupLocation;
  final List<WasteItem> items;
  final Timestamp pickupTime;
  final PickupStatus status;
  final int estimatedPoints;
  final String? orderNote;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  PickupOrder({
    required this.id,
    required this.userId,
    required this.userName,
    required this.address,
    required this.pickupLocation,
    required this.items,
    required this.pickupTime,
    required this.status,
    required this.estimatedPoints,
    this.orderNote,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Konversi instance PickupOrder menjadi Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'address': address,
      'pickupLocation': pickupLocation,
      // Konversi setiap WasteItem di list menjadi Map
      'items': items.map((item) => item.toJson()).toList(),
      'pickupTime': pickupTime,
      'status': status.name, // Simpan status sebagai String
      'estimatedPoints': estimatedPoints,
      'orderNote': orderNote,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Buat instance PickupOrder dari snapshot dokumen Firestore.
  factory PickupOrder.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Missing data for PickupOrder ID: ${doc.id}');
    }

    // Konversi list of maps dari Firestore kembali menjadi List<WasteItem>
    final itemsList = (data['items'] as List<dynamic>?)
        ?.map((itemMap) => WasteItem.fromMap(itemMap as Map<String, dynamic>))
        .toList() ?? [];

    return PickupOrder(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      address: data['address'] ?? 'Alamat tidak tersedia',
      pickupLocation: data['pickupLocation'] ?? const GeoPoint(0,0),
      items: itemsList,
      pickupTime: data['pickupTime'] ?? Timestamp.now(),
      // Ambil status dari string, default ke pending jika tidak ada/salah
      status: PickupStatus.values.firstWhere(
            (e) => e.name == data['status'],
        orElse: () => PickupStatus.pending,
      ),
      estimatedPoints: data['estimatedPoints'] ?? 0,
      orderNote: data['orderNote'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }
}