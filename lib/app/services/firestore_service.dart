import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cemungut_app/app/models/app_user.dart';
import 'package:cemungut_app/app/models/address.dart';
import 'package:flutter/foundation.dart';
import 'package:cemungut_app/app/models/pickup_order.dart';
import 'package:cemungut_app/app/models/reward_item.dart';
import 'package:cemungut_app/app/models/quiz_question.dart';
import 'package:cemungut_app/app/models/education_article.dart';

import '../models/bank_sampah.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // The collection reference for the 'users' collection
  static final CollectionReference<Map<String, dynamic>> _usersCollection =
  _firestore.collection('users');

  static final CollectionReference<Map<String, dynamic>> _wasteBanksCollection =
  _firestore.collection(
    'wasteBanks',
  ); // Assuming this is your collection name

  static final CollectionReference<Map<String, dynamic>>
  _pickupOrderCollection = _firestore.collection('pickupOrder');

  static final CollectionReference<Map<String, dynamic>> _rewardsCollection =
  _firestore.collection('rewards');

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
        points: 0,
        isGoldMember: false,
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

  static Future<void> createPickupOrder(PickupOrder order) async {
    try {
      // Menggunakan ID dari order object sebagai document ID
      await _pickupOrderCollection.doc(order.id).set(order.toJson());
      if (kDebugMode) {
        print('Pickup order created successfully with ID: ${order.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating pickup order: $e');
      }
      rethrow;
    }
  }

  static Future<void> deletePickupOrder(String orderId) async {
    try {
      await _pickupOrderCollection.doc(orderId).delete();
      if (kDebugMode) {
        print('Pickup order deleted successfully: $orderId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting pickup order: $e');
      }
      rethrow;
    }
  }

  static Future<void> updatePickupOrderStatus({
    required String orderId,
    required PickupStatus status,
  }) async {
    try {
      await _pickupOrderCollection.doc(orderId).update({
        'status': status.name,
        'updatedAt': Timestamp.now(),
      });
      if (kDebugMode) {
        print('Pickup order $orderId status updated to ${status.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating pickup order status: $e');
      }
      rethrow;
    }
  }

  static Future<List<PickupOrder>> getPickupOrdersForUser(String userId) async {
    try {
      final querySnapshot =
      await _pickupOrderCollection
          .where('userId', isEqualTo: userId)
      // Urutkan berdasarkan yang paling baru
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PickupOrder.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching pickup orders: $e');
      }
      return []; // Kembalikan list kosong jika terjadi error
    }
  }

  static Future<List<RewardItem>> getRewards() async {
    try {
      final snapshot = await _rewardsCollection.orderBy('pointsRequired').get();
      return snapshot.docs.map((doc) => RewardItem.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching rewards: $e');
      }
      return [];
    }
  }

  static Future<void> redeemPoints({
    required String userId,
    required int pointsToDeduct,
  }) async {
    try {
      final userRef = _usersCollection.doc(userId);

      // Menggunakan nilai negatif untuk mengurangi poin
      await userRef.update({
        'points': FieldValue.increment(-pointsToDeduct),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error redeeming points: $e');
      }
      rethrow;
    }
  }

  static Future<void> completeTransactionAndAddPoints({
    required String userId,
    required int basePoints,
    required String orderId,
  }) async {
    // Jika tidak ada poin, cukup update status pesanan
    if (basePoints <= 0) {
      await updatePickupOrderStatus(orderId: orderId, status: PickupStatus.completed);
      return;
    }

    final userRef = _usersCollection.doc(userId);

    // Gunakan transaction untuk memastikan operasi aman
    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw Exception("User does not exist!");
      }

      final userData = AppUser.fromFirestore(userSnapshot as DocumentSnapshot<Map<String, dynamic>>);
      int pointsToAdd = basePoints;

      // 1. Cek apakah user sudah Gold Member, jika ya, tambahkan bonus 3%
      if (userData.isGoldMember) {
        pointsToAdd = (basePoints * 1.03).round();
      }

      final int newTotalPoints = userData.points + pointsToAdd;
      bool shouldBecomeGold = false;

      // 2. Cek apakah user akan menjadi Gold Member setelah transaksi ini
      // Hanya cek jika user BELUM menjadi Gold Member
      if (!userData.isGoldMember && newTotalPoints >= 350) { // Goal Point = 350
        shouldBecomeGold = true;
      }

      // Siapkan data untuk di-update
      final Map<String, dynamic> updates = {
        'points': FieldValue.increment(pointsToAdd),
        'updatedAt': Timestamp.now(),
      };

      if (shouldBecomeGold) {
        updates['isGoldMember'] = true;
      }

      // 3. Update data user
      transaction.update(userRef, updates);

      // 4. Update status pesanan
      final orderRef = _pickupOrderCollection.doc(orderId);
      transaction.update(orderRef, {
        'status': PickupStatus.completed.name,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  static Future<List<QuizQuestion>> getQuizQuestions({int limit = 10}) async {
    try {
      // Ambil SEMUA dokumen dulu karena Firestore tidak bisa .shuffle() secara native
      QuerySnapshot snapshot =
      await _firestore
          .collection('quiz_questions')
          .get(); // <-- Menggunakan _firestore

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final docs = snapshot.docs;
      docs.shuffle(); // Acak urutan semua dokumen

      // Ambil sejumlah 'limit' dari daftar yang sudah diacak
      final limitedDocs = docs.take(limit);

      return limitedDocs.map((doc) {
        return QuizQuestion.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        // <-- Menggunakan kDebugMode
        print("Error getting quiz questions: $e");
      }
      return [];
    }
  }

  static Future<List<EducationArticle>> getEducationArticles() async {
    try {
      final snapshot =
      await _firestore
          .collection('articles')
          .orderBy(
        'createdAt',
        descending: true,
      ) // Urutkan berdasarkan yang terbaru
          .get();

      return snapshot.docs
          .map((doc) => EducationArticle.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching education articles: $e');
      }
      // Return an empty list on error to prevent the UI from crashing
      return [];
    }
  }

  static CollectionReference<Address> _addressesRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('addresses').withConverter<Address>(
      fromFirestore: (snapshot, _) => Address.fromSnapshot(snapshot),
      toFirestore: (address, _) => address.toJson(),
    );
  }

  static Stream<List<Address>> getAddresses(String userId) {
    return _addressesRef(userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  // Mengambil satu alamat default (atau yang pertama)
  static Future<Address?> getFirstAddress(String userId) async {
    final snapshot = await _addressesRef(userId).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  // Menambah alamat baru
  static Future<void> addAddress(String userId, Address address) {
    final newDocRef = _addressesRef(userId).doc();
    // Kita buat Address baru dengan ID dari dokumen yang baru dibuat
    final addressWithId = Address(
        id: newDocRef.id,
        name: address.name,
        addressDetail: address.addressDetail,
        note: address.note,
        location: address.location);
    return newDocRef.set(addressWithId);
  }

  // Mengupdate alamat
  static Future<void> updateAddress(String userId, Address address) {
    return _addressesRef(userId).doc(address.id).update(address.toJson());
  }

  // Menghapus alamat
  static Future<void> deleteAddress(String userId, String addressId) {
    return _addressesRef(userId).doc(addressId).delete();
  }

}