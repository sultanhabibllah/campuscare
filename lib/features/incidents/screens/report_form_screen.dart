import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/incident.dart';
import '../../../data/repositories/incident_repository.dart';
import '../../auth/cubit/auth_cubit.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key, this.existing});
  final Incident? existing;
  @override State<ReportFormScreen> createState() => _ReportFormScreenState();
}
class _ReportFormScreenState extends State<ReportFormScreen> {
  final form = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.existing?.title ?? '');
  late final description = TextEditingController(text: widget.existing?.description ?? '');
  late String category = widget.existing?.category ?? 'Facilities';
  late String location = widget.existing?.location ?? AppConstants.locations.first;
  File? photo;
  bool busy = false;
  @override void dispose() { title.dispose(); description.dispose(); super.dispose(); }
  Future<void> pickPhoto() async {
    try {
      final selected = await ImagePicker().pickImage(source: ImageSource.gallery,
        maxWidth: 1600, imageQuality: 80);
      if (selected != null && mounted) setState(() => photo = File(selected.path));
    } catch (e) { if (mounted) showAppError(context, e); }
  }
  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      final repo = context.read<IncidentRepository>();
      if (widget.existing != null) {
        await repo.editSubmitted(widget.existing!, title: title.text,
          description: description.text, category: category, location: location);
      } else {
        final auth = context.read<AuthCubit>();
        final uid = auth.state.user!.uid;
        final profile = await auth.repo.getProfile();
        await repo.create(uid: uid, reporterName: profile?.fullName ??
          auth.state.user?.displayName ?? 'Student', title: title.text,
          description: description.text, category: category,
          location: location, photo: photo);
      }
      if (mounted) { Navigator.pop(context, true); }
    } catch (e) { if (mounted) showAppError(context, e); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.existing == null ? 'Report an incident' : 'Edit report')),
    body: SafeArea(child: Form(key: form, child: ListView(padding: const EdgeInsets.all(20), children: [
      Text('Select a category', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12), Wrap(spacing: 9, runSpacing: 9,
        children: AppConstants.categories.map((name) => ChoiceChip(
          label: Text(name), selected: category == name,
          onSelected: (_) => setState(() => category = name),
        )).toList()),
      const SizedBox(height: 24), const FormFieldLabel('Title'),
      TextFormField(controller: title, maxLength: 80,
        decoration: const InputDecoration(hintText: 'Briefly describe the issue'),
        validator: (v) => (v?.trim().length ?? 0) >= 5 ? null : 'Enter at least 5 characters'),
      const SizedBox(height: 12), const FormFieldLabel('Description'),
      TextFormField(controller: description, maxLines: 5, maxLength: 1500,
        decoration: const InputDecoration(hintText: 'What happened, when, and who is affected?'),
        validator: (v) => (v?.trim().length ?? 0) >= 15 ? null : 'Add at least 15 characters'),
      const SizedBox(height: 12), const FormFieldLabel('Location'),
      DropdownButtonFormField<String>(initialValue: location,
        items: AppConstants.locations.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (v) => setState(() => location = v ?? location)),
      const SizedBox(height: 20),
      if (widget.existing == null) ...[
        const FormFieldLabel('Add a photo (optional)'),
        OutlinedButton.icon(onPressed: pickPhoto, icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(photo == null ? 'Choose photo from gallery' : 'Change photo')),
        if (photo != null) Padding(padding: const EdgeInsets.only(top: 12),
          child: ClipRRect(borderRadius: BorderRadius.circular(14),
            child: Image.file(photo!, height: 160, fit: BoxFit.cover))),
      ],
      const SizedBox(height: 28), FilledButton(onPressed: busy ? null : submit,
        child: busy ? const CircularProgressIndicator(color: Colors.white) :
          Text(widget.existing == null ? 'Submit report' : 'Save changes')),
      const SizedBox(height: 12), const Text('Only report issues you have observed. Avoid including sensitive personal information.',
        textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted, fontSize: 12)),
    ]))));
}
