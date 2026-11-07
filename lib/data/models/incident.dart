import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  const Incident({required this.id, required this.reporterId, required this.reporterName,
    required this.title, required this.description, required this.category,
    required this.location, required this.status, required this.createdAt,
    this.photoUrl, this.photoPath, this.updatedAt, this.statusHistory = const []});
  final String id;
  final String reporterId;
  final String reporterName;
  final String title;
  final String description;
  final String category;
  final String location;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? photoUrl;
  final String? photoPath;
  final List<Map<String, dynamic>> statusHistory;

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return Incident(
      id: doc.id,
      reporterId: d['reporterId'] as String? ?? '',
      reporterName: d['reporterName'] as String? ?? '',
      title: d['title'] as String? ?? '',
      description: d['description'] as String? ?? '',
      category: d['category'] as String? ?? 'Other',
      location: d['location'] as String? ?? '',
      status: d['status'] as String? ?? 'Submitted',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
      photoUrl: d['photoUrl'] as String?, photoPath: d['photoPath'] as String?,
      statusHistory: (d['statusHistory'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map)).toList(),
    );
  }
}
