import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'verify_email_status_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(authProvider.notifier).register(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
            passwordConfirmation: _confirmCtrl.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const VerifyEmailStatusScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GlassBackground(child: SizedBox.expand()),
          Positioned(top: -50, left: -60, child: GlassBlob(size: 220, opacity: 0.11)),
          Positioned(bottom: 60, right: -50, child: GlassBlob(size: 160, opacity: 0.09)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: GlassCard(
                        borderRadius: 12,
                        padding: const EdgeInsets.all(10),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: primary),
                      ),
                    ).animate().fadeIn(duration: 300.ms),

                    const SizedBox(height: 28),

                    // ── Logo ─────────────────────────────────────────────────
                    Center(
                      child: GlassCard(
                        borderRadius: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Image.asset(
                          'assets/images/lovi-horizontal.png',
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'Create account 🌱',
                      style: GoogleFonts.poppins(
                          fontSize: 28, fontWeight: FontWeight.w700, color: onSurface),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 4),
                    Text(
                      'Sign up to get started',
                      style: GoogleFonts.poppins(fontSize: 15, color: onSurfaceVariant),
                    ).animate().fadeIn(delay: 150.ms),

                    const SizedBox(height: 28),

                    GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Full Name
                          TextFormField(
                            controller: _nameCtrl,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Name is required';
                              if (v.trim().length < 2) return 'Enter your full name';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Email is required';
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
                                return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password is required';
                              if (v.length < 8) return 'Minimum 8 characters';
                              return null;
                            },
                          ),

                          if (_passwordCtrl.text.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _PasswordStrengthBar(password: _passwordCtrl.text),
                          ],

                          const SizedBox(height: 14),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: _obscureConfirm,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Please confirm your password';
                              if (v != _passwordCtrl.text)
                                return 'Passwords do not match';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 24),

                    GradientButton(
                      onPressed: isLoading ? null : _register,
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : const Text('Create Account',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                    ).animate().fadeIn(delay: 350.ms),

                    const SizedBox(height: 16),

                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Already have an account? Sign In',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Password Strength Bar ────────────────────────────────────────────────────

class _PasswordStrengthBar extends StatelessWidget {
  final String password;
  const _PasswordStrengthBar({required this.password});

  int get _score {
    int s = 0;
    if (password.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(password)) s++;
    if (RegExp(r'[0-9]').hasMatch(password)) s++;
    if (RegExp(r'[!@#\$&*~%^()_\-+=]').hasMatch(password)) s++;
    return s;
  }

  Color get _color => switch (_score) {
        1 => const Color(0xFFD62828),
        2 => const Color(0xFFE07B2A),
        3 => const Color(0xFF2D9B5E),
        4 => Colors.green.shade700,
        _ => Colors.grey.shade300,
      };

  String get _label => switch (_score) {
        1 => 'Weak',
        2 => 'Fair',
        3 => 'Good',
        4 => 'Strong',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: i < _score ? _color : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )),
        ),
        const SizedBox(height: 5),
        Text('Strength: $_label',
            style: TextStyle(
                color: _color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
