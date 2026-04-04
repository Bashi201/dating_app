import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/register_screen.dart';
import '../auth/forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authProvider.notifier)
        .login(email: _emailCtrl.text.trim(), password: _passCtrl.text.trim());
    if (!mounted) return;
    final state = ref.read(authProvider);
    state.whenOrNull(
      error: (e, _) {
        final message = e.toString();
        final isUnverified = message.contains('verify');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isUnverified
                  ? '📧 Please verify your email before signing in.'
                  : message,
            ),
            backgroundColor: isUnverified ? Colors.orange : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
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
          Positioned(
            top: -70,
            right: -50,
            child: GlassBlob(size: 240, opacity: 0.13),
          ),
          Positioned(
            bottom: 80,
            left: -60,
            child: GlassBlob(size: 180, opacity: 0.10),
          ),
          Positioned(
            top: 200,
            left: -40,
            child: GlassBlob(size: 100, opacity: 0.07),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),

                    // ── Logo ─────────────────────────────────────────────────
                    Center(
                      child:
                          GlassCard(
                                borderRadius: 28,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 24,
                                ),
                                child: Image.asset(
                                  'assets/images/lovi-stacked.png',
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .slideY(begin: -0.2, end: 0),
                    ),

                    const SizedBox(height: 36),

                    Text(
                      'Welcome back 👋',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                      ),
                    ).animate().fadeIn(delay: 150.ms),

                    const SizedBox(height: 4),
                    Text(
                      'Sign in to continue',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: onSurfaceVariant,
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 28),

                    // ── Input Glass Card ──────────────────────────────────────
                    GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Email is required';
                                  if (!v.contains('@'))
                                    return 'Enter a valid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Password is required';
                                  if (v.length < 8)
                                    return 'Minimum 8 characters';
                                  return null;
                                },
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  ),
                                  child: Text(
                                    'Forgot password?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 24),

                    // ── Gradient Login Button ────────────────────────────────
                    GradientButton(
                      onPressed: isLoading ? null : _login,
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: Text(
                          "Don't have an account? Sign Up",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 450.ms),

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
