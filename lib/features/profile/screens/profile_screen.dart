import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/app_user.dart';
import '../../auth/cubit/auth_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>();
    return Scaffold(appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<AppUser?>(future: auth.repo.getProfile(), builder: (context, snap) {
        final user = snap.data;
        return ListView(padding: const EdgeInsets.all(24), children: [
          const Center(child: CircleAvatar(radius: 43,
            backgroundColor: AppTheme.pale, child: Icon(Icons.person,
              color: AppTheme.green, size: 52))),
          const SizedBox(height: 18), Text(user?.fullName ?? auth.state.user?.displayName ?? 'CampusCare member',
            style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
          Text(auth.state.user?.email ?? '', textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 14), Center(child: Chip(label: Text(auth.state.staff ? 'Campus staff' : 'Student'))),
          const SizedBox(height: 35), const SectionHeading('Account'),
          const SizedBox(height: 16), Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.verified_user_outlined), title: const Text('Email verification'),
              trailing: const Text('Verified', style: TextStyle(color: AppTheme.green))),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.info_outline), title: const Text('About CampusCare'),
              subtitle: const Text('Report issues and follow their resolution at ALU')),
          ])),
          const SizedBox(height: 22), OutlinedButton.icon(onPressed: () => auth.logout(),
            icon: const Icon(Icons.logout), label: const Text('Log out')),
        ]);
      }));
  }
}
