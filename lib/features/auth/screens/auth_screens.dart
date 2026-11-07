
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../cubit/auth_cubit.dart';

// =====================================================
// LOGIN SCREEN
// =====================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!form.currentState!.validate()) return;

    try {
      await context.read<AuthCubit>().login(
        email.text.trim(),
        password.text,
      );
    } catch (error) {
      if (mounted) showAppError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              const CampusPhotoHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  24, 0, 24, 35,
                ),
                child: Form(
                  key: form,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome back',
                        style: Theme.of(context)
                            .textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Log in to report campus issues '
                        'and track their resolution.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 35),
                      const FormFieldLabel('Email address'),
                      TextFormField(
                        controller: email,
                        keyboardType:
                            TextInputType.emailAddress,
                        textInputAction:
                            TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.email,
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Enter your email',
                          prefixIcon:
                              Icon(Icons.mail_outline),
                        ),
                        validator: (value) {
                          final text =
                              value?.trim() ?? '';

                          if (text.isEmpty) {
                            return 'Email is required';
                          }

                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(text)) {
                            return 'Enter a valid email address';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const FormFieldLabel('Password'),
                      PasswordInput(
                        controller: password,
                        hint: 'Enter your password',
                        validator: (value) =>
                            (value?.isNotEmpty ?? false)
                                ? null
                                : 'Password is required',
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ResetPasswordScreen(),
                            ),
                          ),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: AppTheme.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return FilledButton(
                            onPressed:
                                state.busy ? null : login,
                            child: state.busy
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('Log in'),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const SignupScreen(),
                              ),
                            ),
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// SIGN UP SCREEN
// =====================================================

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() =>
      _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final form = GlobalKey<FormState>();

  final first = TextEditingController();
  final last = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  String? validateName(String? value) {
    return (value?.trim().isNotEmpty ?? false)
        ? null
        : 'Required';
  }

  Future<void> createAccount() async {
    if (!form.currentState!.validate()) return;

    try {
      await context.read<AuthCubit>().register(
        first.text.trim(),
        last.text.trim(),
        email.text.trim(),
        password.text,
      );

      if (!mounted) return;

      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
    } catch (error) {
      if (mounted) showAppError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              const CampusPhotoHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  24, 0, 24, 32,
                ),
                child: Form(
                  key: form,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: 'Back to login',
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppTheme.ink,
                          ),
                          onPressed: () =>
                              Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create an account',
                        style: Theme.of(context)
                            .textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Set up your account to report '
                        'issues and get timely updates.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                const FormFieldLabel(
                                  'First name',
                                ),
                                TextFormField(
                                  controller: first,
                                  validator: validateName,
                                  textCapitalization:
                                      TextCapitalization.words,
                                  decoration:
                                      const InputDecoration(
                                    hintText: 'First name',
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                const FormFieldLabel(
                                  'Last name',
                                ),
                                TextFormField(
                                  controller: last,
                                  validator: validateName,
                                  textCapitalization:
                                      TextCapitalization.words,
                                  decoration:
                                      const InputDecoration(
                                    hintText: 'Last name',
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      const FormFieldLabel('ALU Email'),
                      TextFormField(
                        controller: email,
                        keyboardType:
                            TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'name@alustudent.com',
                          prefixIcon:
                              Icon(Icons.mail_outline),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!AppConstants.validCampusEmail(
                            value,
                          )) {
                            return 'Use an @alustudent.com email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),
                      const FormFieldLabel('Password'),
                      PasswordInput(
                        controller: password,
                        hint: 'Create a password',
                        validator: (value) =>
                            (value?.length ?? 0) >= 8
                                ? null
                                : 'Use at least 8 characters',
                      ),
                      const SizedBox(height: 18),
                      const FormFieldLabel('Confirm password'),
                      PasswordInput(
                        controller: confirm,
                        hint: 'Confirm your password',
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Confirm your password';
                          }
                          return value == password.text
                              ? null
                              : 'Passwords do not match';
                        },
                      ),

                      const SizedBox(height: 30),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return FilledButton(
                            onPressed: state.busy
                                ? null
                                : createAccount,
                            child: state.busy
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('Sign up'),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            child: const Text('Log in'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// EMAIL VERIFICATION
// =====================================================

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context
            .read<AuthCubit>()
            .state.user?.email ??
        'your email';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 88,
                  color: AppTheme.green,
                ),
                const SizedBox(height: 22),
                Text(
                  'Verify your email',
                  style: Theme.of(context)
                      .textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'We sent a verification link to '
                  '$email. Open it and return here '
                  'to continue.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.muted,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () async {
                    await context
                        .read<AuthCubit>()
                        .refresh();
                  },
                  child: const Text(
                    "I've verified my email",
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await context
                          .read<AuthCubit>()
                          .repo
                          .resendVerification();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Verification email sent.',
                            ),
                          ),
                        );
                      }
                    } catch (error) {
                      if (context.mounted) {
                        showAppError(context, error);
                      }
                    }
                  },
                  child: const Text(
                    'Resend verification link',
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.read<AuthCubit>().logout(),
                  child: const Text('Log out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// PASSWORD RESET
// =====================================================

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();

  bool busy = false;

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<void> sendResetLink() async {
    if (!form.currentState!.validate()) return;

    setState(() => busy = true);

    try {
      await context
          .read<AuthCubit>()
          .repo
          .resetPassword(email.text.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'If this email is registered, '
            'a reset link will arrive shortly.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (mounted) showAppError(context, error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.lock_reset_outlined,
                  size: 72,
                  color: AppTheme.green,
                ),
                const SizedBox(height: 20),
                Text(
                  'Forgot your password?',
                  style: Theme.of(context)
                      .textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Enter your registered email to '
                  'receive a password reset link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.muted,
                  ),
                ),
                const SizedBox(height: 32),
                const FormFieldLabel('Email address'),
                TextFormField(
                  controller: email,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon:
                        Icon(Icons.mail_outline),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(text)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: busy ? null : sendResetLink,
                  child: busy
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Send reset link'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
