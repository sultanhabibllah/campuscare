import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';

enum AuthPhase { loading, signedOut, verifyEmail, signedIn }
class AuthState {
  const AuthState(this.phase, {this.user, this.staff = false, this.busy = false, this.error});
  final AuthPhase phase;
  final User? user;
  final bool staff;
  final bool busy;
  final String? error;
  AuthState copyWith({bool? busy, String? error}) => AuthState(phase,
    user: user, staff: staff, busy: busy ?? this.busy, error: error);
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.repo) : super(const AuthState(AuthPhase.loading)) {
    _subscription = repo.authChanges.listen((_) => refresh());
  }
  final AuthRepository repo;
  late final StreamSubscription<User?> _subscription;
  Future<void> refresh() async {
    final user = repo.currentUser;
    if (user == null) {
      emit(const AuthState(AuthPhase.signedOut)); return;
    }
    try {
      await repo.reloadUser();
      final current = repo.currentUser;
      if (current == null) { emit(const AuthState(AuthPhase.signedOut)); return; }
      if (!current.emailVerified) {
        emit(AuthState(AuthPhase.verifyEmail, user: current)); return;
      }
      final staff = await repo.isStaff();
      emit(AuthState(AuthPhase.signedIn, user: current, staff: staff));
    } catch (e) { emit(AuthState(AuthPhase.verifyEmail, user: user, error: e.toString())); }
  }
  Future<void> register(String first, String last, String email, String pass) async {
    emit(state.copyWith(busy: true));
    try { await repo.register(firstName: first, lastName: last, email: email, password: pass);
      await refresh();
    } catch (e) { emit(state.copyWith(busy: false, error: e.toString())); rethrow; }
  }
  Future<void> login(String email, String pass) async {
    emit(state.copyWith(busy: true));
    try { await repo.login(email, pass); await refresh(); }
    catch (e) { emit(state.copyWith(busy: false, error: e.toString())); rethrow; }
  }
  Future<void> logout() async => repo.logout();
  @override
  Future<void> close() async { await _subscription.cancel(); return super.close(); }
}
