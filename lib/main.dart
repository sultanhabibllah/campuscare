
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/incident_repository.dart';

import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/screens/auth_screens.dart';
import 'features/incidents/cubit/incidents_cubit.dart';

import 'shell/app_shell.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CampusCareApp());
}

class CampusCareApp extends StatelessWidget {
  const CampusCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
    );

    final incidentRepository = IncidentRepository(
      FirebaseFirestore.instance,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(
          value: authRepository,
        ),
        RepositoryProvider<IncidentRepository>.value(
          value: incidentRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(authRepository),
          ),
        ],
        child: MaterialApp(
          title: 'CampusCare',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        switch (state.phase) {
          case AuthPhase.loading:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );

          case AuthPhase.signedOut:
            return const LoginScreen();

          case AuthPhase.verifyEmail:
            return const VerifyEmailScreen();

          case AuthPhase.signedIn:
            return BlocProvider<IncidentsCubit>(
              key: ValueKey(state.user!.uid),
              create: (context) => IncidentsCubit(
                context.read<IncidentRepository>(),
              ),
              child: const AppShell(),
            );
        }
      },
    );
  }
}
