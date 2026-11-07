import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/incident.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../incidents/cubit/incidents_cubit.dart';
import '../../incidents/screens/incident_detail_screen.dart';
import '../../incidents/screens/report_form_screen.dart';
import '../../incidents/widgets/incident_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final all = context.watch<IncidentsCubit>().state;
    final userItems = all.items.where((e) => e.reporterId == auth.user?.uid).toList();
    final name = auth.user?.displayName?.split(' ').first ?? 'Student';
    return Scaffold(body: SafeArea(child: RefreshIndicator(
      onRefresh: () => context.read<AuthCubit>().refresh(),
      child: ListView(padding: const EdgeInsets.all(20), children: [
        const CampusLogo(), const SizedBox(height: 27),
        Text('Hello, $name 👋', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 5), const Text('Help keep our campus running smoothly.',
          style: TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 25), Container(
          decoration: BoxDecoration(color: AppTheme.green, borderRadius: BorderRadius.circular(24)),
          child: Padding(padding: const EdgeInsets.all(22), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.campaign_outlined, color: Colors.white, size: 37),
              const SizedBox(height: 12), const Text('Spot an issue on campus?',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5), const Text('Report it and help improve our learning environment.',
                style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 18), FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.green),
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const ReportFormScreen())),
                icon: const Icon(Icons.add_circle_outline), label: const Text('Report an issue')),
            ]))),
        const SizedBox(height: 26), const SectionHeading('Report summary'),
        const SizedBox(height: 14), Row(children: [
          _SummaryCard('My Reports', userItems.length, Icons.description_outlined),
          const SizedBox(width: 8),
          _SummaryCard('In Progress', userItems.where((e) => e.status == 'In Progress').length,
            Icons.timelapse_outlined),
          const SizedBox(width: 8),
          _SummaryCard('Resolved', userItems.where((e) => e.status == 'Resolved').length,
            Icons.task_alt),
        ]),
        const SizedBox(height: 26), const SectionHeading('Recent reports'),
        const SizedBox(height: 14),
        if (all.loading) const Center(child: CircularProgressIndicator())
        else if (all.error != null) Text('Could not load reports: ${all.error}')
        else if (userItems.isEmpty) const EmptyPanel(icon: Icons.note_add_outlined,
          title: 'No reports yet', detail: 'Submit your first issue and track its progress here.')
        else ...userItems.take(4).map((Incident item) => IncidentCard(item: item,
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => IncidentDetailScreen(id: item.id))))),
      ]))));
  }
}
class _SummaryCard extends StatelessWidget {
  const _SummaryCard(this.label, this.count, this.icon);
  final String label;
  final int count;
  final IconData icon;
  @override Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 17),
    decoration: BoxDecoration(color: AppTheme.pale, borderRadius: BorderRadius.circular(16)),
    child: Column(children: [Icon(icon, color: AppTheme.green),
      const SizedBox(height: 7), Text('$count', style: const TextStyle(fontSize: 24,
        fontWeight: FontWeight.w800, color: AppTheme.ink)),
      const SizedBox(height: 3), Text(label, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, color: AppTheme.muted))])));
}
