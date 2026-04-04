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
                  ? 'Please verify your email before signing in.'
                  : message,
            ),
            backgroundColor: isUnverified
                ? const Color(0xFFB45309)
                : const Color(0xFF991B1B),
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

    // Brand palette derived from the lovi logo
    const crimson = Color(0xFF9B1C3A);
    const deepCrimson = Color(0xFF6B0F26);
    const roseBlush = Color(0xFFF7D6DC);
    const warmCream = Color(0xFFFDF4F0);
    const darkInk = Color(0xFF1A0A0D);
    const mutedWine = Color(0xFF7A3040);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? roseBlush.withOpacity(0.85) : mutedWine.withOpacity(0.75);
    final hintColor = isDark ? roseBlush.withOpacity(0.40) : crimson.withOpacity(0.28);
    final iconColor = isDark ? roseBlush.withOpacity(0.65) : crimson.withOpacity(0.45);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Rich layered background ───────────────────────────────────────
          const GlassBackground(child: SizedBox.expand()),

          // Signature Glass Blobs - the "nice circles" for brand consistency
          const Positioned(
            top: -100,
            right: -80,
            child: GlassBlob(size: 320, opacity: 0.12),
          ),
          const Positioned(
            bottom: 60,
            left: -90,
            child: GlassBlob(size: 260, opacity: 0.10),
          ),
          const Positioned(
            top: 260,
            right: -30,
            child: GlassBlob(size: 140, opacity: 0.08),
          ),

          // ── Main content ─────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 52),

                    // ── Hero Logo Section ────────────────────────────────────
                    // Full-bleed, no card cage around it — let the logo breathe
                    Center(
                      child: Column(
                        children: [
                          // Logo image — displayed generously without a box
                          Image.asset(
                                'assets/images/lovi-stacked.png',
                                height: 110,
                                fit: BoxFit.contain,
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                              .scale(
                                begin: const Offset(0.88, 0.88),
                                end: const Offset(1.0, 1.0),
                                duration: 700.ms,
                                curve: Curves.easeOutBack,
                              ),

                          const SizedBox(height: 16),

                          // Elegant thin rule — replaces the card border
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 36,
                                height: 1,
                                color: crimson.withOpacity(0.25),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Fresh from the garden',
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 13,
                                    letterSpacing: 1.8,
                                    color: isDark ? roseBlush.withOpacity(0.70) : mutedWine.withOpacity(0.60),
                                    fontStyle: FontStyle.italic,
                                  ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 36,
                                height: 1,
                                color: crimson.withOpacity(0.25),
                              ),
                            ],
                          ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                        ],
                      ),
                    ),

                    const SizedBox(height: 44),

                    // ── Heading block ────────────────────────────────────────
                    Text(
                          'Welcome back',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 180.ms, duration: 400.ms)
                        .slideX(begin: -0.06, end: 0),

                    const SizedBox(height: 6),

                    Text(
                      'Sign in to continue',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        letterSpacing: 0.2,
                      ),
                    ).animate().fadeIn(delay: 240.ms, duration: 400.ms),

                    const SizedBox(height: 30),

                    // ── Thin decorative accent line ──────────────────────────
                    Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: [crimson, deepCrimson],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .scaleX(
                          begin: 0,
                          end: 1,
                          alignment: Alignment.centerLeft,
                          duration: 500.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: 28),

                    // ── Input card ───────────────────────────────────────────
                    GlassCard(
                          borderRadius: 22,
                          padding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email label + field
                              _FieldLabel('Email address', labelColor),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.poppins(fontSize: 14),
                                decoration: _inputDecoration(
                                  hint: 'you@example.com',
                                  icon: Icons.alternate_email_rounded,
                                  hintColor: hintColor,
                                  iconColor: iconColor,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Email is required';
                                  if (!v.contains('@'))
                                    return 'Enter a valid email';
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // Password label + field
                              _FieldLabel('Password', labelColor),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                style: GoogleFonts.poppins(fontSize: 14),
                                decoration:
                                    _inputDecoration(
                                      hint: '••••••••',
                                      icon: Icons.lock_outline_rounded,
                                      hintColor: hintColor,
                                      iconColor: iconColor,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 20,
                                          color: isDark ? roseBlush.withOpacity(0.60) : mutedWine.withOpacity(0.55),
                                        ),
                                        onPressed: () => setState(
                                          () => _obscure = !_obscure,
                                        ),
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

                              // Forgot password — right-aligned, no card bloat
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 12,
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
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
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: crimson,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 340.ms, duration: 450.ms)
                        .slideY(begin: 0.12, end: 0, curve: Curves.easeOut),

                    const SizedBox(height: 26),

                    // ── Premium Sign In Button ───────────────────────────────
                    GradientButton(
                      onPressed: isLoading ? null : _login,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Sign In',
                              style: GoogleFonts.poppins(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                    ).animate().fadeIn(delay: 430.ms, duration: 400.ms),

                    const SizedBox(height: 24),

                    // ── Register link — refined, no emoji ───────────────────
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'New to lovi?',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.only(left: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            ),
                            child: Text(
                              'Create an account',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: crimson,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 480.ms, duration: 400.ms),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _FieldLabel(String text, Color color) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: color,
    ),
  );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color hintColor,
    required Color iconColor,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(
      fontSize: 13.5,
      color: hintColor,
    ),
    prefixIcon: Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Icon(
        icon,
        size: 19,
        color: iconColor,
      ),
    ),
    // Remove the label — we're using our own _FieldLabel above
    labelText: null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: const Color(0xFF9B1C3A).withOpacity(0.15)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: const Color(0xFF9B1C3A).withOpacity(0.15)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF9B1C3A), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF991B1B)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF991B1B), width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    filled: true,
    fillColor: const Color(0xFF9B1C3A).withOpacity(0.04),
  );
}
