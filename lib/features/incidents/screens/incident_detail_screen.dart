import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/incident.dart';
import '../../../data/repositories/incident_repository.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../widgets/incident_widgets.dart';
import 'report_form_screen.dart';
import '../../staff/screens/staff_update_screen.dart';

class IncidentDetailScreen extends StatelessWidget {
  const IncidentDetailScreen({super.key, required this.id});
  final String id;
  @override Widget build(BuildContext context) {
    final repo = context.read<IncidentRepository>();
    return Scaffold(appBar: AppBar(title: const Text('Incident details')),
      body: StreamBuilder<Incident?>(stream: repo.watchOne(id), builder: (context, snap) {
        if (snap.hasError) {
          return EmptyPanel(icon: Icons.error_outline,
          title: 'Unable to open report', detail: '${snap.error}');
        }
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final item = snap.data;
        if (item == null) {
          return const EmptyPanel(icon: Icons.search_off,
          title: 'Report not found', detail: 'It may have been deleted.');
        }
        final auth = context.watch<AuthCubit>().state;
        final isOwner = auth.user?.uid == item.reporterId;
        final canEdit = isOwner && item.status == 'Submitted';
        return ListView(padding: const EdgeInsets.all(20), children: [
          if (item.photoUrl != null) ClipRRect(borderRadius: BorderRadius.circular(20),
            child: Image.network(item.photoUrl!, height: 210, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 180, color: AppTheme.pale,
                child: const Icon(Icons.broken_image_outlined)))),
          const SizedBox(height: 20), Text(item.title,
            style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10), Row(children: [StatusPill(status: item.status),
            const Spacer(), Text(item.category,
              style: const TextStyle(color: AppTheme.muted))]),
          const SizedBox(height: 18),
          Text('Location: ${item.location}'),
          Text('Reported by: ${item.reporterName}',
            style: const TextStyle(color: AppTheme.muted)),
          Text('Submitted: ${DateFormat('MMM d, yyyy • h:mm a').format(item.createdAt)}',
            style: const TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 28), const SectionHeading('Status timeline'),
          const SizedBox(height: 10),
          _TimelineRow(label: 'Submitted', active: true, detail: DateFormat('MMM d, h:mm a').format(item.createdAt)),
          _TimelineRow(label: 'In Progress', active: ['In Progress', 'Resolved'].contains(item.status),
            detail: _firstTime(item, 'In Progress')),
          _TimelineRow(label: 'Resolved', active: item.status == 'Resolved',
            detail: _firstTime(item, 'Resolved')),
          if (item.statusHistory.isNotEmpty) ...[
            const SizedBox(height: 16), const SectionHeading('Staff updates'),
            ...item.statusHistory.map((row) => ListTile(
              contentPadding: EdgeInsets.zero, leading: const Icon(Icons.check_circle_outline,
                color: AppTheme.green), title: Text('${row['status']}'),
              subtitle: Text((row['note'] as String? ?? '').trim().isEmpty
                ? 'Status updated' : row['note'] as String),
            )),
          ],
          const SizedBox(height: 24), const SectionHeading('Description'),
          const SizedBox(height: 8), Text(item.description,
            style: const TextStyle(fontSize: 15, height: 1.6)),
          if (auth.staff) ...[
            const SizedBox(height: 24), FilledButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => StaffUpdateScreen(item: item))),
              icon: const Icon(Icons.edit_note), label: const Text('Update status')),
          ],
          if (canEdit) ...[
            const SizedBox(height: 24), OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ReportFormScreen(existing: item))),
              icon: const Icon(Icons.edit_outlined), label: const Text('Edit report')),
            TextButton.icon(onPressed: () async {
              final confirmed = await showDialog<bool>(context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Delete report?'),
                  content: const Text('This cannot be undone.'), actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
                  ]));
              if (confirmed != true || !context.mounted) return;
              try { await repo.deleteSubmitted(item);
                if (context.mounted) Navigator.pop(context);
              } catch (e) { if (context.mounted) showAppError(context, e); }
            }, icon: const Icon(Icons.delete_outline), label: const Text('Delete report')),
          ],
        ]);
      }));
  }
  String _firstTime(Incident item, String status) {
    for (final row in item.statusHistory) {
      if (row['status'] == status && row['at'] != null) {
        final at = row['at'];
        if (at is Timestamp) return DateFormat('MMM d, h:mm a').format(at.toDate());
      }
    }
    return 'Pending';
  }
}
class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.label, required this.active, required this.detail});
  final String label;
  final bool active;
  final String detail;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(children: [Icon(active ? Icons.check_circle : Icons.radio_button_unchecked,
      color: active ? AppTheme.green : Colors.grey), const SizedBox(width: 12),
      Expanded(child: Text(label, style: TextStyle(fontWeight: active ? FontWeight.w700 : FontWeight.w400))),
      Text(detail, style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
    ]));
}
