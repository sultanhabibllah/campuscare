import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/incident.dart';

class IncidentRepository {
  IncidentRepository(this.db, this.storage);
  final FirebaseFirestore db;
  final FirebaseStorage storage;
  CollectionReference<Map<String, dynamic>> get _incidents => db.collection('incidents');

  Stream<List<Incident>> watchAll() => _incidents.orderBy('createdAt', descending: true)
      .snapshots().map((snap) => snap.docs.map(Incident.fromDoc).toList());
  Stream<Incident?> watchOne(String id) => _incidents.doc(id).snapshots()
      .map((doc) => doc.exists ? Incident.fromDoc(doc) : null);

  Future<void> create({required String uid, required String reporterName,
    required String title, required String description,
    required String category, required String location, File? photo}) async {
    final ref = _incidents.doc();
    String? photoUrl;
    String? photoPath;
    if (photo != null) {
      photoPath = 'incident_photos/$uid/${ref.id}.jpg';
      final storeRef = storage.ref(photoPath);
      await storeRef.putFile(photo, SettableMetadata(contentType: 'image/jpeg'));
      photoUrl = await storeRef.getDownloadURL();
    }
    try {
      await ref.set({
        'reporterId': uid, 'reporterName': reporterName,
        'title': title.trim(), 'description': description.trim(),
        'category': category, 'location': location,
        'photoUrl': photoUrl, 'photoPath': photoPath,
        'status': 'Submitted', 'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'statusHistory': [],
      });
    } catch (_) {
      if (photoPath != null) {
        try { await storage.ref(photoPath).delete(); } catch (_) { /* Best effort. */ }
      }
      rethrow;
    }
  }

  Future<void> editSubmitted(Incident old, {required String title,
    required String description, required String category, required String location}) async {
    await _incidents.doc(old.id).update({
      'title': title.trim(), 'description': description.trim(),
      'category': category, 'location': location,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSubmitted(Incident item) async {
    // Firestore document first. Photo removal afterward is best-effort.
    await _incidents.doc(item.id).delete();
    if (item.photoPath != null) {
      try { await storage.ref(item.photoPath!).delete(); } catch (_) { /* Orphan cleanup can be retried. */ }
    }
  }

  Future<void> updateStatus({required Incident item, required String status,
    required String staffId, required String note}) async {
    await _incidents.doc(item.id).update({
      'status': status, 'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([{
        'status': status, 'by': staffId, 'note': note.trim(),
        'at': Timestamp.now(),
      }]),
    });
  }
}
