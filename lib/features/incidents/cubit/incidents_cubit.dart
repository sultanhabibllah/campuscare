import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/incident.dart';
import '../../../data/repositories/incident_repository.dart';

class IncidentsState {
  const IncidentsState({this.items = const [], this.loading = true, this.error});
  final List<Incident> items;
  final bool loading;
  final String? error;
}
class IncidentsCubit extends Cubit<IncidentsState> {
  IncidentsCubit(IncidentRepository repo) : super(const IncidentsState()) {
    _subscription = repo.watchAll().listen(
      (items) => emit(IncidentsState(items: items, loading: false)),
      onError: (Object e) => emit(IncidentsState(loading: false, error: e.toString())),
    );
  }
  late final StreamSubscription<List<Incident>> _subscription;
  @override
  Future<void> close() async { await _subscription.cancel(); return super.close(); }
}
