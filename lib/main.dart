import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/incident_repository.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/screens/auth_screens.dart';
import 'features/incidents/cubit/incidents_cubit.dart';
import 'shell/app_shell.dart';
import 'firebase_options.dart'; // Generated locally by `flutterfire configure`.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CampusCareApp());
}

class CampusCareApp extends StatelessWidget {
  const CampusCareApp({super.key});
  @override Widget build(BuildContext context) {
    final authRepo = AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
    final incidentRepo = IncidentRepository(FirebaseFirestore.instance, FirebaseStorage.instance);
    return MultiRepositoryProvider(providers: [
      RepositoryProvider<AuthRepository>.value(value: authRepo),
      RepositoryProvider<IncidentRepository>.value(value: incidentRepo),
    ], child: MultiBlocProvider(providers: [
      BlocProvider(create: (_) => AuthCubit(authRepo)),
    ], child: MaterialApp(title: 'CampusCare', debugShowCheckedModeBanner: false,
      theme: AppTheme.light, home: const _AuthGate())));
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();
  @override Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (context, state) => switch (state.phase) {
      AuthPhase.loading => const Scaffold(body: Center(child: CircularProgressIndicator())),
      AuthPhase.signedOut => const LoginScreen(),
      AuthPhase.verifyEmail => const VerifyEmailScreen(),
      AuthPhase.signedIn => BlocProvider(
        key: ValueKey(state.user!.uid),
        create: (context) => IncidentsCubit(context.read<IncidentRepository>()),
        child: const AppShell()),
    },
  );
}
