import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../cubit/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  @override void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child:
    SingleChildScrollView(child: Column(children: [
      const CampusPhotoHeader(),
      Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 35), child: Form(
        key: form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Welcome back', style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Log in to report campus issues and track their resolution.',
            textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted, fontSize: 16)),
          const SizedBox(height: 35), const FormFieldLabel('ALU Email'),
          TextFormField(controller: email, keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email], decoration: const InputDecoration(
              hintText: 'name@alu.edu', prefixIcon: Icon(Icons.mail_outline)),
            validator: (v) => AppConstants.validCampusEmail(v ?? '') ? null :
              'Use your ALU email (@${AppConstants.aluEmailDomain})'),
          const SizedBox(height: 20), const FormFieldLabel('Password'),
          PasswordInput(controller: password, hint: 'Enter your password',
            validator: (v) => (v?.isNotEmpty ?? false) ? null : 'Password is required'),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen())),
            child: const Text('Forgot password?', style: TextStyle(color: AppTheme.green)))),
          const SizedBox(height: 18),
          BlocBuilder<AuthCubit, AuthState>(builder: (context, state) => FilledButton(
            onPressed: state.busy ? null : () async {
              if (!form.currentState!.validate()) return;
              try { await context.read<AuthCubit>().login(email.text, password.text); }
              catch (e) { if (context.mounted) showAppError(context, e); }
            }, child: state.busy ? const CircularProgressIndicator(color: Colors.white) : const Text('Log in'))),
          const SizedBox(height: 30), Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text("Don't have an account? "),
            TextButton(onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SignupScreen())), child: const Text('Sign up')),
          ]),
        ]))),
    ]))));
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override State<SignupScreen> createState() => _SignupScreenState();
}
class _SignupScreenState extends State<SignupScreen> {
  final form = GlobalKey<FormState>();
  final first = TextEditingController();
  final last = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  @override void dispose() {
    for (final c in [first, last, email, password, confirm]) { c.dispose(); }
    super.dispose();
  }
  String? requiredName(String? v) => (v?.trim().isNotEmpty ?? false) ? null : 'Required';
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child:
    SingleChildScrollView(child: Column(children: [
      const CampusPhotoHeader(),
      Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 32), child: Form(
        key: form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Create an account', style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: 8), const Text('Set up your account to report issues and get timely updates.',
            textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted, fontSize: 16)),
          const SizedBox(height: 30),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const FormFieldLabel('First name'),
              TextFormField(controller: first, validator: requiredName,
                decoration: const InputDecoration(hintText: 'First name', prefixIcon: Icon(Icons.person_outline))),
            ])), const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const FormFieldLabel('Last name'),
              TextFormField(controller: last, validator: requiredName,
                decoration: const InputDecoration(hintText: 'Last name', prefixIcon: Icon(Icons.person_outline))),
            ])),
          ]), const SizedBox(height: 18), const FormFieldLabel('ALU Email'),
          TextFormField(controller: email, keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'name@alu.edu', prefixIcon: Icon(Icons.mail_outline)),
            validator: (v) => AppConstants.validCampusEmail(v ?? '') ? null :
              'Use an ALU email (@${AppConstants.aluEmailDomain})'),
          const SizedBox(height: 18), const FormFieldLabel('Password'),
          PasswordInput(controller: password, hint: 'Create a password',
            validator: (v) => (v?.length ?? 0) >= 8 ? null : 'Use at least 8 characters'),
          const SizedBox(height: 18), const FormFieldLabel('Confirm password'),
          PasswordInput(controller: confirm, hint: 'Confirm your password',
            validator: (v) => v == password.text ? null : 'Passwords do not match'),
          const SizedBox(height: 30),
          BlocBuilder<AuthCubit, AuthState>(builder: (context, state) => FilledButton(
            onPressed: state.busy ? null : () async {
              if (!form.currentState!.validate()) return;
              try {
                await context.read<AuthCubit>().register(first.text, last.text, email.text, password.text);
                if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
              }
              catch (e) { if (context.mounted) showAppError(context, e); }
            }, child: state.busy ? const CircularProgressIndicator(color: Colors.white) : const Text('Sign up'))),
          const SizedBox(height: 24), Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Already have an account? '),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Log in')),
          ]),
        ]))),
    ]))));
}

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Padding(
    padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.mark_email_unread_outlined, size: 88, color: AppTheme.green),
      const SizedBox(height: 22), Text('Verify your ALU email',
        style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
      const SizedBox(height: 12), Text('We sent a verification link to ${context.read<AuthCubit>().state.user?.email ?? 'your email'}. Open it, then return here.',
        textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted)),
      const SizedBox(height: 32), FilledButton(onPressed: () async {
        await context.read<AuthCubit>().refresh();
      }, child: const Text("I've verified my email")),
      TextButton(onPressed: () async {
        try { await context.read<AuthCubit>().repo.resendVerification();
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification email sent.')));
        } catch (e) { if (context.mounted) showAppError(context, e); }
      }, child: const Text('Resend verification link')),
      TextButton(onPressed: () => context.read<AuthCubit>().logout(), child: const Text('Log out')),
    ]))));
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}
class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final email = TextEditingController();
  @override void dispose() { email.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Reset password')),
    body: Padding(padding: const EdgeInsets.all(24), child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('Enter your ALU email. We will send you a password-reset link.'),
        const SizedBox(height: 24), const FormFieldLabel('ALU Email'),
        TextField(controller: email, keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'name@alu.edu')),
        const SizedBox(height: 20), FilledButton(onPressed: () async {
          try { await context.read<AuthCubit>().repo.resetPassword(email.text);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('If this email is registered, a reset link will arrive shortly.')));
            Navigator.pop(context);
          } catch (e) { if (context.mounted) showAppError(context, e); }
        }, child: const Text('Send reset link')),
      ])));
}
