import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krishi_connect/models/user_model.dart';
import 'package:krishi_connect/utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Phone + PIN login (no OTP by default)
  Future<UserModel?> loginWithPhone(String phone, String pin) async {
    try {
      // Look up user by phone number in Firestore
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('phone', isEqualTo: phone)
          .where('pin', isEqualTo: pin)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Invalid phone number or PIN');
      }

      final userData = querySnapshot.docs.first;
      final email = userData.data()['email'] as String?;

      if (email != null && email.isNotEmpty) {
        // Sign in with email (using phone-derived email if needed)
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: pin,
        );
      } else {
        // Use a derived email from phone for Firebase Auth
        final derivedEmail = '$phone@krishiconnect.app';
        await _auth.signInWithEmailAndPassword(
          email: derivedEmail,
          password: pin,
        );
      }

      return UserModel.fromMap(userData.data(), userData.id);
    } catch (e) {
      rethrow;
    }
  }

  // Email + Password login
  Future<UserModel?> loginWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) throw Exception('Login failed');

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) throw Exception('User data not found');

      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      rethrow;
    }
  }

  // Signup with role
  Future<UserModel?> signup({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String pin,
    required String role,
  }) async {
    try {
      // If no email provided, use phone-derived email
      final loginEmail = email.isNotEmpty ? email : '$phone@krishiconnect.app';

      final credential = await _auth.createUserWithEmailAndPassword(
        email: loginEmail,
        password: password.isNotEmpty ? password : pin,
      );

      if (credential.user == null) throw Exception('Signup failed');

      final user = UserModel(
        uid: credential.user!.uid,
        name: name,
        phone: phone,
        email: email.isNotEmpty ? email : null,
        role: role,
        pin: pin,
        createdAt: DateTime.now(),
        isApproved: role == AppConstants.roleFarmer, // Farmers auto-approved
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .set(user.toMap());

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;

      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      return null;
    }
  }

  // Check if OTP is required (from settings)
  Future<bool> isOtpRequired() async {
    try {
      final doc = await _firestore.doc(AppConstants.settingsAuthDocument).get();
      if (!doc.exists) return false;
      return doc.data()?['otpRequired'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Update user profile
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }
}
