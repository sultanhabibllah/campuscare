import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../models/app_user.dart';

class AuthRepository {
  AuthRepository(this._auth, this._db);
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  Stream<User?> get authChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> register({required String firstName, required String lastName,
    required String email, required String password}) async {
    if (!AppConstants.validCampusEmail(email)) {
      throw Exception('Use your ALU email ending in @${AppConstants.aluEmailDomain}.');
    }
    final result = await _auth.createUserWithEmailAndPassword(
      email: email.trim(), password: password);
    final user = result.user!;
    await user.updateDisplayName('$firstName $lastName');
    await _db.collection('users').doc(user.uid).set({
      'firstName': firstName.trim(), 'lastName': lastName.trim(),
      'email': email.trim().toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    await user.sendEmailVerification();
  }

  Future<void> login(String email, String password) async {
    if (!AppConstants.validCampusEmail(email)) {
      throw Exception('Only verified ALU accounts can sign in.');
    }
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> reloadUser() async => _auth.currentUser?.reload();
  Future<void> resendVerification() async => _auth.currentUser?.sendEmailVerification();
  Future<void> resetPassword(String email) async {
    if (!AppConstants.validCampusEmail(email)) throw Exception('Enter your ALU email.');
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
  Future<void> logout() async => _auth.signOut();

  Future<AppUser?> getProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? AppUser.fromDoc(doc) : null;
  }

  Future<bool> isStaff() async {
    final result = await _auth.currentUser?.getIdTokenResult(true);
    return result?.claims?['staff'] == true;
  }
}
