import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/incident.dart';

Color statusColor(String status) => switch (status) {
  'Resolved' => const Color(0xFF18864B),
  'In Progress' => const Color(0xFF5954DE),
  _ => const Color(0xFFD88B11),
};
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});
  final String status;
  @override Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: .11), borderRadius: BorderRadius.circular(30)),
      child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)));
  }
}
class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.item, required this.onTap});
  final Incident item;
  final VoidCallback onTap;
  @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 67, height: 67,
          child: item.photoUrl != null
            ? Image.network(item.photoUrl!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined))
            : Container(color: AppTheme.pale, child: const Icon(Icons.report_problem_outlined,
                color: AppTheme.green, size: 31)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4), Text(item.location,
            style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
          const SizedBox(height: 4), Text(DateFormat('MMM d, yyyy').format(item.createdAt),
            style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
        ])),
        Column(children: [StatusPill(status: item.status), const SizedBox(height: 8),
          const Icon(Icons.chevron_right, color: AppTheme.muted)]),
      ]))));
}
