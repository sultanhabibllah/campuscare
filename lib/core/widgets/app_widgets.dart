import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CampusLogo extends StatelessWidget {
  const CampusLogo({super.key});
  @override
  Widget build(BuildContext context) => const Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.home_work_rounded, size: 30, color: AppTheme.green),
    SizedBox(width: 8), Text('CampusCare', style: TextStyle(fontSize: 23,
      fontWeight: FontWeight.w800, color: AppTheme.green)),
  ]);
}

class CampusPhotoHeader extends StatelessWidget {
  const CampusPhotoHeader({super.key, this.height = 245});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(height: height,
    width: double.infinity, child: Stack(fit: StackFit.expand, children: [
      Image.asset('assets/images/alu_campus.jpg', fit: BoxFit.cover, alignment: Alignment.center),
      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0x99E7F2EC), Color(0x00E7F2EC), Color(0xFFFBFDFC)],
        stops: [0, .48, 1],
      ))),
      const Positioned(top: 24, left: 24, child: CampusLogo()),
    ]));
}

class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8), child: Text(label,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)));
}

class PasswordInput extends StatefulWidget {
  const PasswordInput({super.key, required this.controller, required this.hint,
    this.validator});
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  @override
  State<PasswordInput> createState() => _PasswordInputState();
}
class _PasswordInputState extends State<PasswordInput> {
  bool obscure = true;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller, obscureText: obscure,
    validator: widget.validator, textInputAction: TextInputAction.next,
    decoration: InputDecoration(hintText: widget.hint,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(tooltip: obscure ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => obscure = !obscure),
        icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined))));
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(text, style: Theme.of(context).textTheme.titleLarge)),
    if (trailing != null) trailing!,
  ]);
}

void showAppError(BuildContext context, Object error) {
  final text = error.toString().replaceFirst('Exception: ', '');
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel({super.key, required this.icon, required this.title, required this.detail});
  final IconData icon;
  final String title;
  final String detail;
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 52, color: AppTheme.green), const SizedBox(height: 12),
      Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
      const SizedBox(height: 6), Text(detail, textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.muted)),
    ])));
}
