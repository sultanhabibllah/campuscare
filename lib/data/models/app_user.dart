import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({required this.uid, required this.firstName,
    required this.lastName, required this.email});
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  String get fullName => '$firstName $lastName'.trim();

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppUser(uid: doc.id, firstName: d['firstName'] as String? ?? '',
      lastName: d['lastName'] as String? ?? '', email: d['email'] as String? ?? '');
  }
}
