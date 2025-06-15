import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cemungut_app/app/models/app_user.dart'; // Make sure this path is correct
import 'package:flutter/foundation.dart';

import '../models/bank_sampah.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // The collection reference for the 'users' collection
  static final CollectionReference<Map<String, dynamic>> _usersCollection =
  _firestore.collection('users');

  static final CollectionReference<Map<String, dynamic>> _wasteBanksCollection =
  _firestore.collection('wasteBanks'); // Assuming this is your collection name

  /// Creates a new user document in Firestore.
  ///
  /// This method should be called right after a new user is created in Firebase Auth.
  /// It takes the user's details and creates an [AppUser] document in the 'users' collection.
  static Future<void> createAppUser({
    required String id,
    required String name,
    required String email,
    required String phoneNumber, // phoneNumber is optional
  }) async {
    try {
      final now = Timestamp.now();

      // Create an AppUser object with the provided data
      final appUser = AppUser(
        id: id,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        photoUrl: null, // No photo URL at registration
        createdAt: now,
        updatedAt: now,
      );

      // Set the document in the 'users' collection with the user's UID as the document ID
      await _usersCollection.doc(id).set(appUser.toJson());

      if (kDebugMode) {
        print('Firestore user document created successfully for user ID: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating Firestore user document: $e');
      }
      // Re-throw the error to be handled by the calling function (e.g., in the UI)
      rethrow;
    }
  }

  /// Fetches a user document from Firestore by their ID.
  ///
  /// Returns an [AppUser] object if the document exists, otherwise returns null.
  static Future<AppUser?> getAppUser(String id) async {
    try {
      final docSnapshot = await _usersCollection.doc(id).get();
      if (docSnapshot.exists) {
        return AppUser.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user document: $e');
      }
      return null;
    }
  }

  static Future<void> updateUserData({
    required String id,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      await _usersCollection.doc(id).update({
        'name': name,
        'phoneNumber': phoneNumber,
        'updatedAt': Timestamp.now(), // Always update the timestamp
      });

      if (kDebugMode) {
        print('Firestore user document updated successfully for user ID: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating Firestore user document: $e');
      }
      rethrow;
    }
  }

  static Future<List<BankSampah>> getWasteBanks() async {
    try {
      final snapshot = await _wasteBanksCollection.get();
      // Convert each document into a BankSampah object
      return snapshot.docs.map((doc) => BankSampah.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching waste banks: $e');
      }
      return []; // Return an empty list on error
    }
  }
}