import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/incident.dart';
import '../../../data/repositories/incident_repository.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../incidents/widgets/incident_widgets.dart';

class StaffUpdateScreen extends StatefulWidget {
  const StaffUpdateScreen({super.key, required this.item});
  final Incident item;
  @override State<StaffUpdateScreen> createState() => _StaffUpdateScreenState();
}
class _StaffUpdateScreenState extends State<StaffUpdateScreen> {
  late String status = widget.item.status;
  final note = TextEditingController();
  bool busy = false;
  @override void dispose() { note.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Update incident')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text(widget.item.title, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8), Text(widget.item.location,
        style: const TextStyle(color: AppTheme.muted)),
      const SizedBox(height: 16), Row(children: [const Text('Current status: '),
        StatusPill(status: widget.item.status)]),
      const SizedBox(height: 34), const FormFieldLabel('Update status'),
      DropdownButtonFormField<String>(initialValue: status,
        items: ['Submitted', 'In Progress', 'Resolved'].map((v) =>
          DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (v) => setState(() => status = v ?? status)),
      const SizedBox(height: 20), const FormFieldLabel('Update note (optional)'),
      TextField(controller: note, maxLines: 4, maxLength: 400,
        decoration: const InputDecoration(hintText: 'Explain what has been done or what happens next...')),
      const SizedBox(height: 20), FilledButton(onPressed: busy || status == widget.item.status ? null : () async {
        setState(() => busy = true);
        try {
          if (!context.read<AuthCubit>().state.staff) {
            throw Exception('Staff authorization is required.');
          }
          await context.read<IncidentRepository>().updateStatus(
            item: widget.item, status: status,
            staffId: context.read<AuthCubit>().state.user!.uid, note: note.text);
          if (context.mounted) Navigator.pop(context);
        } catch (e) { if (context.mounted) showAppError(context, e); }
        finally { if (mounted) setState(() => busy = false); }
      }, child: busy ? const CircularProgressIndicator(color: Colors.white) :
        const Text('Save status update')),
    ]));
}
