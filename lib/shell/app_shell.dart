import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/cubit/auth_cubit.dart';
import '../features/home/screens/home_screen.dart';
import '../features/incidents/screens/report_form_screen.dart';
import '../features/incidents/screens/reports_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/staff/screens/staff_dashboard_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override State<AppShell> createState() => _AppShellState();
}
class _AppShellState extends State<AppShell> {
  int index = 0;
  @override Widget build(BuildContext context) {
    final staff = context.watch<AuthCubit>().state.staff;
    final screens = staff
      ? const [StaffDashboardScreen(), ReportsScreen(), ProfileScreen()]
      : const [HomeScreen(), ReportsScreen(), ProfileScreen()];
    return Scaffold(body: IndexedStack(index: index, children: screens),
      floatingActionButton: staff ? null : FloatingActionButton(
        backgroundColor: AppTheme.green, foregroundColor: Colors.white,
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ReportFormScreen())),
        child: const Icon(Icons.add)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          NavigationDestination(icon: Icon(staff ? Icons.dashboard_outlined : Icons.home_outlined),
            selectedIcon: Icon(staff ? Icons.dashboard : Icons.home), label: staff ? 'Dashboard' : 'Home'),
          const NavigationDestination(icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article), label: 'Reports'),
          const NavigationDestination(icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person), label: 'Profile'),
        ]));
  }
}
