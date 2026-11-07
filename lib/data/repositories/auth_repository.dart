
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_constants.dart';
import '../models/app_user.dart';

class AuthRepository {
  AuthRepository(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> get authChanges =>
      _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // --------------------------------------------------
  // STUDENT REGISTRATION
  // --------------------------------------------------

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final normalizedEmail =
        email.trim().toLowerCase();

    if (!AppConstants.validCampusEmail(normalizedEmail)) {
      throw Exception(
        'Registration requires an '
        '@${AppConstants.aluEmailDomain} email.',
      );
    }

    final result =
        await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final user = result.user!;

    await user.updateDisplayName(
      '${firstName.trim()} ${lastName.trim()}',
    );

    await _db.collection('users').doc(user.uid).set({
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'email': normalizedEmail,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await user.sendEmailVerification();
  }

  // --------------------------------------------------
  // STUDENT AND STAFF LOGIN
  // --------------------------------------------------

  Future<void> login(
    String email,
    String password,
  ) async {
    final normalizedEmail =
        email.trim().toLowerCase();

    if (!normalizedEmail.contains('@')) {
      throw Exception(
        'Enter a valid email address.',
      );
    }

    final result =
        await _auth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final user = result.user!;

    // Refresh the token to retrieve current claims.
    final token = await user.getIdTokenResult(true);

    final isStaff =
        token.claims?['staff'] == true;

    final isStudent = AppConstants.validCampusEmail(
      user.email ?? '',
    );

    // Gmail accounts cannot enter merely because
    // they know a password.
    //
    // Non-student accounts need a securely assigned
    // Firebase staff claim.
    if (!isStudent && !isStaff) {
      await _auth.signOut();

      throw Exception(
        'Only verified ALU students and '
        'authorized campus staff can sign in.',
      );
    }
  }

  // --------------------------------------------------
  // SESSION MANAGEMENT
  // --------------------------------------------------

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> resendVerification() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user is signed in.');
    }

    await user.sendEmailVerification();
  }

  Future<void> resetPassword(String email) async {
    final normalizedEmail =
        email.trim().toLowerCase();

    if (!normalizedEmail.contains('@')) {
      throw Exception(
        'Enter a valid email address.',
      );
    }

    await _auth.sendPasswordResetEmail(
      email: normalizedEmail,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // --------------------------------------------------
  // FIRESTORE PROFILE
  // --------------------------------------------------

  Future<AppUser?> getProfile() async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) return null;

    final doc = await _db
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) return null;

    return AppUser.fromDoc(doc);
  }

  // --------------------------------------------------
  // STAFF AUTHORIZATION
  // --------------------------------------------------

  Future<bool> isStaff() async {
    final user = _auth.currentUser;

    if (user == null) return false;

    final token = await user.getIdTokenResult(true);

    return token.claims?['staff'] == true;
  }
}
