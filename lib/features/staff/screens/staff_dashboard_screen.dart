
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';

import '../../incidents/cubit/incidents_cubit.dart';
import '../../incidents/screens/incident_detail_screen.dart';
import '../../incidents/widgets/incident_widgets.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<IncidentsCubit>().state;
    final items = state.items;

    final submittedCount = items
        .where((item) => item.status == 'Submitted')
        .length;

    final inProgressCount = items
        .where((item) => item.status == 'In Progress')
        .length;

    final resolvedCount = items
        .where((item) => item.status == 'Resolved')
        .length;

    final pendingItems = items
        .where((item) => item.status != 'Resolved')
        .toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const CampusLogo(),

            const SizedBox(height: 26),

            Text(
              'Staff dashboard',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 6),

            const Text(
              'Campus incidents at a glance',
              style: TextStyle(
                color: AppTheme.muted,
              ),
            ),

            const SizedBox(height: 24),

            // Dashboard overview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.green,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Campus incident overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _Metric(
                        label: 'Total',
                        count: items.length,
                      ),

                      _Metric(
                        label: 'New',
                        count: submittedCount,
                      ),

                      _Metric(
                        label: 'Active',
                        count: inProgressCount,
                      ),

                      _Metric(
                        label: 'Resolved',
                        count: resolvedCount,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const SectionHeading('Needs attention'),

            const SizedBox(height: 14),

            if (state.loading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (state.error != null)
              Text(
                'Unable to load incidents: ${state.error}',
              )
            else if (pendingItems.isEmpty)
              const EmptyPanel(
                icon: Icons.task_alt,
                title: 'All caught up',
                detail: 'There are no unresolved incidents.',
              )
            else
              ...pendingItems.take(8).map(
                (item) => IncidentCard(
                  item: item,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IncidentDetailScreen(
                          id: item.id,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.count,
  });

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 5),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 3,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.green,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
