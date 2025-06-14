import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart'; // Import the new Firestore service

class FirebaseAuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Private constructor to prevent instantiation
  FirebaseAuthService._();

  static Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  static User? get currentUser => _firebaseAuth.currentUser;

  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) {
        print('User signed in: ${userCredential.user?.uid}');
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Failed to sign in: ${e.message}');
      }
      return null;
    }
  }

  /// Signs up a user with email and password, and creates their document in Firestore.
  static Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phoneNumber, // Added phoneNumber
  }) async {
    try {
      // Step 1: Create the user in Firebase Authentication
      UserCredential userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) {
        print('Firebase Auth user created: ${userCredential.user?.uid}');
      }

      User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Optionally, update the display name in Firebase Auth
        await firebaseUser.updateDisplayName(name);

        // Step 2: Create the corresponding user document in Firestore
        try {
          await FirestoreService.createAppUser(
            id: firebaseUser.uid, // Use the UID from Auth as the document ID
            name: name,
            email: email,
            phoneNumber: phoneNumber,
          );
        } catch (e) {
          // IMPORTANT: If Firestore creation fails, we should handle it.
          // For now, we'll print an error. In a production app, you might want
          // to delete the auth user to prevent inconsistent states.
          if (kDebugMode) {
            print('CRITICAL: Auth user was created, but Firestore document creation failed: $e');
          }
          // You could re-throw the error or return null to indicate failure.
          return null;
        }
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Failed to sign up: ${e.message}');
      }
      return null;
    }
  }

  static Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  static Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}