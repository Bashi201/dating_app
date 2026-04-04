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

    // Brand palette derived from the lovi logo
    const crimson = Color(0xFF9B1C3A);
    const deepCrimson = Color(0xFF6B0F26);
    const roseBlush = Color(0xFFF7D6DC);
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

          // Warm ambient orbs — replacing harsh blobs with soft glows
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [crimson.withOpacity(0.18), crimson.withOpacity(0.0)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    deepCrimson.withOpacity(0.14),
                    deepCrimson.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 260,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    roseBlush.withOpacity(0.10),
                    roseBlush.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ── Back button ──────────────────────────────────────────
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: crimson.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: crimson.withOpacity(0.12),
                          ),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: crimson),
                      ),
                    ).animate().fadeIn(duration: 300.ms),

                    const SizedBox(height: 12),

                    // ── Hero Logo Section ────────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                                'assets/images/lovi-stacked.png',
                                height: 80,
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
                          const SizedBox(height: 12),
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

                    const SizedBox(height: 24),

                    // ── Heading block ────────────────────────────────────────
                    Text(
                          'Create account',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 30,
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
                      'Sign up to get started',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        letterSpacing: 0.2,
                      ),
                    ).animate().fadeIn(delay: 240.ms, duration: 400.ms),

                    const SizedBox(height: 16),

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

                    const SizedBox(height: 18),

                    // ── Input card ───────────────────────────────────────────
                    GlassCard(
                      borderRadius: 22,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full Name label + field
                          _FieldLabel('Full Name', labelColor),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _nameCtrl,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: _inputDecoration(
                              hint: 'Your name',
                              icon: Icons.person_outline_rounded,
                              hintColor: hintColor,
                              iconColor: iconColor,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Name is required';
                              if (v.trim().length < 2) return 'Enter your full name';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Email label + field
                          _FieldLabel('Email address', labelColor),
                          const SizedBox(height: 4),
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
                              if (v == null || v.trim().isEmpty) return 'Email is required';
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
                                return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password label + field
                          _FieldLabel('Password', labelColor),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            onChanged: (_) => setState(() {}),
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: _inputDecoration(
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              hintColor: hintColor,
                              iconColor: iconColor,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: isDark ? roseBlush.withOpacity(0.60) : mutedWine.withOpacity(0.55),
                                ),
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
                            const SizedBox(height: 8),
                            _PasswordStrengthBar(password: _passwordCtrl.text),
                          ],

                          const SizedBox(height: 14),

                          // Confirm Password label + field
                          _FieldLabel('Confirm Password', labelColor),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: _obscureConfirm,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: _inputDecoration(
                              hint: '••••••••',
                              icon: Icons.shield_outlined,
                              hintColor: hintColor,
                              iconColor: iconColor,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: isDark ? roseBlush.withOpacity(0.60) : mutedWine.withOpacity(0.55),
                                ),
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
                    ).animate().fadeIn(delay: 340.ms, duration: 450.ms).slideY(begin: 0.12, end: 0, curve: Curves.easeOut),

                    const SizedBox(height: 18),

                    // ── Premium Create Account Button ──────────────────────────────
                    GradientButton(
                      onPressed: isLoading ? null : _register,
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
                              'Create Account',
                              style: GoogleFonts.poppins(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                    ).animate().fadeIn(delay: 430.ms, duration: 400.ms),

                    const SizedBox(height: 16),

                    // ── Footer link ─────────────────────────────────────────
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Already have an account?',
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
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Sign In',
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

                    const SizedBox(height: 24),
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
