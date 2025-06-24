import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phoneNumber; // Can be null
  final String? photoUrl;    // Can be null
  final int points;
  final bool isGoldMember;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.photoUrl,
    required this.points,
    this.isGoldMember = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converts an AppUser instance into a JSON map.
  /// This is used when writing data to Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'points': points,
      'isGoldMember': isGoldMember,
      'createdAt': createdAt,
      'updatedAt': updatedAt,

    };
  }

  /// Creates an AppUser instance from a Firestore document snapshot.
  /// This is used when reading data from Firestore.
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      // Handle the case where the document is empty or doesn't exist.
      throw StateError('Missing data for AppUser ID: ${doc.id}');
    }

    return AppUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'], // Will be null if not present
      photoUrl: data['photoUrl'],       // Will be null if not present
      points: data['points'] ?? 0,
      isGoldMember: data['isGoldMember'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }
}