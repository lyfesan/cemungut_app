import 'package:cloud_firestore/cloud_firestore.dart';

class BankSampah {
  final String id;
  final String name;
  final String description;
  final String operationalTime;
  final String operationalDay;
  final GeoPoint location; // Crucial for map coordinates

  BankSampah({
    required this.id,
    required this.name,
    required this.description,
    required this.operationalTime,
    required this.operationalDay,
    required this.location,
  });

  factory BankSampah.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return BankSampah(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      operationalTime: data['operationalTime'] ?? '',
      operationalDay: data['operationalDay'] ?? '',
      // Default to a 0,0 location if the geopoint is missing
      location: data['location'] ?? const GeoPoint(0, 0),
    );
  }
}