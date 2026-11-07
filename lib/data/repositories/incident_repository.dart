
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/cloudinary_config.dart';
import '../models/incident.dart';

class IncidentRepository {
  IncidentRepository(this.db);

  final FirebaseFirestore db;

  CollectionReference<Map<String, dynamic>> get _incidents =>
      db.collection('incidents');

  // ---------------------------------------------------
  // READ ALL INCIDENTS
  // ---------------------------------------------------

  Stream<List<Incident>> watchAll() {
    return _incidents
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(Incident.fromDoc)
              .toList(),
        );
  }

  // ---------------------------------------------------
  // READ A SINGLE INCIDENT
  // ---------------------------------------------------

  Stream<Incident?> watchOne(String id) {
    return _incidents.doc(id).snapshots().map(
      (document) {
        if (!document.exists) {
          return null;
        }

        return Incident.fromDoc(document);
      },
    );
  }

  // ---------------------------------------------------
  // UPLOAD IMAGE TO CLOUDINARY
  // ---------------------------------------------------

  Future<String> uploadImage(File image) async {
    if (!CloudinaryConfig.isConfigured) {
      throw Exception(
        'Cloudinary is not configured. '
        'Check cloudinary_config.dart.',
      );
    }

    if (!await image.exists()) {
      throw Exception('Selected image was not found.');
    }

    final fileSize = await image.length();

    if (fileSize > 5 * 1024 * 1024) {
      throw Exception(
        'Image is too large. Maximum size is 5 MB.',
      );
    }

    final uri = Uri.parse(
      CloudinaryConfig.uploadUrl,
    );

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.fields['upload_preset'] =
        CloudinaryConfig.uploadPreset;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        image.path,
      ),
    );

    try {
      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      Map<String, dynamic> result;

      try {
        result = jsonDecode(response.body)
            as Map<String, dynamic>;
      } catch (_) {
        throw Exception(
          'Cloudinary returned an invalid response.',
        );
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        final errorData = result['error'];

        String message = 'Image upload failed.';

        if (errorData is Map) {
          message =
              errorData['message']?.toString() ?? message;
        }

        throw Exception(message);
      }

      final secureUrl = result['secure_url'];

      if (secureUrl is! String ||
          !secureUrl.startsWith('https://')) {
        throw Exception(
          'Cloudinary did not return a valid image URL.',
        );
      }

      return secureUrl;
    } on SocketException {
      throw Exception(
        'No internet connection. Check your network.',
      );
    } on http.ClientException catch (error) {
      throw Exception(
        'Image upload failed: ${error.message}',
      );
    }
  }

  // ---------------------------------------------------
  // CREATE INCIDENT
  // ---------------------------------------------------

  Future<void> create({
    required String uid,
    required String reporterName,
    required String title,
    required String description,
    required String category,
    required String location,
    File? photo,
  }) async {
    final incidentRef = _incidents.doc();

    String? photoUrl;

    // Upload only when a photograph was selected.
    if (photo != null) {
      photoUrl = await uploadImage(photo);
    }

    // Save the incident in Cloud Firestore.
    await incidentRef.set({
      'reporterId': uid,
      'reporterName': reporterName,
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'location': location,

      // Image URL returned by Cloudinary.
      'photoUrl': photoUrl,

      // No Firebase Storage path is used.
      'photoPath': null,

      'status': 'Submitted',

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),

      'statusHistory': [],
    });
  }

  // ---------------------------------------------------
  // UPDATE A SUBMITTED INCIDENT
  // ---------------------------------------------------

  Future<void> editSubmitted(
    Incident old, {
    required String title,
    required String description,
    required String category,
    required String location,
  }) async {
    if (old.status != 'Submitted') {
      throw Exception(
        'Only submitted incidents can be edited.',
      );
    }

    await _incidents.doc(old.id).update({
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'location': location,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------
  // DELETE A SUBMITTED INCIDENT
  // ---------------------------------------------------

  Future<void> deleteSubmitted(Incident item) async {
    if (item.status != 'Submitted') {
      throw Exception(
        'Only submitted incidents can be deleted.',
      );
    }

    await _incidents.doc(item.id).delete();

    // Cloudinary images are not deleted from the
    // mobile client because secure deletion requires
    // server-side authentication.
    //
    // Asset cleanup will be handled separately.
  }

  // ---------------------------------------------------
  // STAFF: UPDATE INCIDENT STATUS
  // ---------------------------------------------------

  Future<void> updateStatus({
    required Incident item,
    required String status,
    required String staffId,
    required String note,
  }) async {
    const validStatuses = [
      'Submitted',
      'In Progress',
      'Resolved',
    ];

    if (!validStatuses.contains(status)) {
      throw Exception('Invalid incident status.');
    }

    if (status == item.status) {
      throw Exception(
        'Choose a different status.',
      );
    }

    await _incidents.doc(item.id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),

      'statusHistory': FieldValue.arrayUnion([
        {
          'status': status,
          'by': staffId,
          'note': note.trim(),
          'at': Timestamp.now(),
        },
      ]),
    });
  }
}
