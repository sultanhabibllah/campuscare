
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../cubit/auth_cubit.dart';

// ============================================================
// LOGIN SCREEN
// ============================================================

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CampusPhotoHeader(),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  0,
                  24,
                  35,
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
                            .textTheme
                            .headlineLarge,
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

                      const FormFieldLabel('ALU Email'),

                      TextFormField(
                        controller: email,
                        keyboardType:
                            TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.email,
                        ],
                        decoration: const InputDecoration(
                          hintText: 'name@alustudent.com',
                          prefixIcon: Icon(
                            Icons.mail_outline,
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Email is required';
                          }

                          if (!AppConstants.validCampusEmail(
                            value,
                          )) {
                            return 'Use your ALU student email';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      const FormFieldLabel('Password'),

                      PasswordInput(
                        controller: password,
                        hint: 'Enter your password',
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Password is required';
                          }

                          return null;
                        },
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ResetPasswordScreen(),
                              ),
                            );
                          },
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
                            onPressed: state.busy
                                ? null
                                : () async {
                                    if (!form.currentState!
                                        .validate()) {
                                      return;
                                    }

                                    try {
                                      await context
                                          .read<AuthCubit>()
                                          .login(
                                            email.text.trim(),
                                            password.text,
                                          );
                                    } catch (error) {
                                      if (context.mounted) {
                                        showAppError(
                                          context,
                                          error,
                                        );
                                      }
                                    }
                                  },
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SignupScreen(),
                                ),
                              );
                            },
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

// ============================================================
// SIGN UP SCREEN
// ============================================================

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
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

  String? requiredName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  Future<void> createAccount() async {
    if (!form.currentState!.validate()) {
      return;
    }

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
      if (mounted) {
        showAppError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CampusPhotoHeader(),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  0,
                  24,
                  32,
                ),
                child: Form(
                  key: form,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create an account',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Set up your account to report issues '
                        'and get timely updates.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // First name and last name
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
                                  validator: requiredName,
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
                                  validator: requiredName,
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
                        textInputAction: TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.email,
                        ],
                        decoration: const InputDecoration(
                          hintText: 'name@alustudent.com',
                          prefixIcon: Icon(
                            Icons.mail_outline,
                          ),
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
                        validator: (value) {
                          if (value == null ||
                              value.length < 8) {
                            return 'Use at least 8 characters';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      const FormFieldLabel(
                        'Confirm password',
                      ),

                      PasswordInput(
                        controller: confirm,
                        hint: 'Confirm your password',
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Confirm your password';
                          }

                          if (value != password.text) {
                            return 'Passwords do not match';
                          }

                          return null;
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
                            onPressed: () {
                              Navigator.pop(context);
                            },
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

// ============================================================
// EMAIL VERIFICATION SCREEN
// ============================================================

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = context
            .read<AuthCubit>()
            .state
            .user
            ?.email ??
        'your ALU email';

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
                  'Verify your ALU email',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'We sent a verification link to '
                  '$userEmail.\n\n'
                  'Open the link in your inbox, '
                  'then return to CampusCare.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 32),

                FilledButton(
                  onPressed: () async {
                    try {
                      await context
                          .read<AuthCubit>()
                          .refresh();
                    } catch (error) {
                      if (context.mounted) {
                        showAppError(context, error);
                      }
                    }
                  },
                  child: const Text(
                    "I've verified my email",
                  ),
                ),

                const SizedBox(height: 12),

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

                const SizedBox(height: 8),

                TextButton(
                  onPressed: () {
                    context.read<AuthCubit>().logout();
                  },
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

// ============================================================
// PASSWORD RESET SCREEN
// ============================================================

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
    if (!form.currentState!.validate()) {
      return;
    }

    setState(() {
      busy = true;
    });

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
            'a password reset link will arrive shortly.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        showAppError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
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
                      .textTheme
                      .headlineMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Enter your ALU student email. '
                  'We will send you a link to reset '
                  'your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.muted,
                  ),
                ),

                const SizedBox(height: 32),

                const FormFieldLabel('ALU Email'),

                TextFormField(
                  controller: email,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'name@alustudent.com',
                    prefixIcon: Icon(
                      Icons.mail_outline,
                    ),
                  ),
                  validator: (value) {
                    if (!AppConstants.validCampusEmail(
                      value ?? '',
                    )) {
                      return 'Enter a valid ALU student email';
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
