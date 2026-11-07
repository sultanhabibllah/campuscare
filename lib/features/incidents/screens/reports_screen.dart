
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/app_widgets.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../cubit/incidents_cubit.dart';
import '../widgets/incident_widgets.dart';
import 'incident_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';

  final List<String> filters = [
    'All',
    'Submitted',
    'In Progress',
    'Resolved',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final incidentsState = context.watch<IncidentsCubit>().state;

    // Students see their own reports.
    // Staff can see all reports.
    final visibleReports = incidentsState.items.where((item) {
      return auth.staff || item.reporterId == auth.user?.uid;
    }).toList();

    // Apply search and status filters.
    final filteredReports = visibleReports.where((item) {
      final matchesStatus =
          selectedFilter == 'All' ||
          item.status == selectedFilter;

      final searchableText = [
        item.title,
        item.description,
        item.location,
        item.category,
      ].join(' ').toLowerCase();

      final matchesSearch = searchableText.contains(
        searchQuery.toLowerCase(),
      );

      return matchesStatus && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          auth.staff ? 'All reports' : 'My reports',
        ),
      ),

      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search incidents...',
              ),
            ),
          ),

          // Status filter chips
          SizedBox(
            height: 65,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              children: filters.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: selectedFilter == filter,
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Reports list
          Expanded(
            child: incidentsState.loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : incidentsState.error != null
                    ? EmptyPanel(
                        icon: Icons.error_outline,
                        title: 'Unable to load reports',
                        detail: incidentsState.error!,
                      )
                    : filteredReports.isEmpty
                        ? const EmptyPanel(
                            icon: Icons.search_off,
                            title: 'No matching reports',
                            detail:
                                'Try a different search or filter.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              6,
                              20,
                              20,
                            ),
                            itemCount: filteredReports.length,
                            itemBuilder: (context, index) {
                              final item = filteredReports[index];

                              return IncidentCard(
                                item: item,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          IncidentDetailScreen(
                                            id: item.id,
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
