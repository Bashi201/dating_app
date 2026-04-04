import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _sendResetLink() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).forgotPassword(email: _emailCtrl.text.trim());
      if (!mounted) return;
      setState(() => _emailSent = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isLoading;

    const crimson = Color(0xFF9B1C3A);
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

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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

                  if (_emailSent)
                    _successView(crimson, labelColor, isDark)
                  else
                    _emailView(labelColor, hintColor, iconColor, isLoading, isDark, roseBlush, mutedWine),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailView(Color labelColor, Color hintColor, Color iconColor, bool isLoading, bool isDark, Color roseBlush, Color mutedWine) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Heading block ────────────────────────────────────────
          Text(
                'Forgot password?',
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
            "Enter your email to receive a reset link",
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
                    colors: [Color(0xFF9B1C3A), Color(0xFF6B0F26)],
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

          GlassCard(
            borderRadius: 22,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter a valid email';
                    return null;
                  },
                ),
              ],
            ),
          ).animate().fadeIn(delay: 340.ms, duration: 450.ms).slideY(begin: 0.12, end: 0, curve: Curves.easeOut),

          const SizedBox(height: 18),

          GradientButton(
            onPressed: isLoading ? null : _sendResetLink,
            child: isLoading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    'Send Reset Link',
                    style: GoogleFonts.poppins(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
          ).animate().fadeIn(delay: 430.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _successView(Color crimson, Color labelColor, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 20),
        GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined, size: 40, color: Colors.green),
              ),
              const SizedBox(height: 24),
              Text('Check your email',
                  style: GoogleFonts.cormorantGaramond(
                      fontSize: 28, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 12),
              Text('We sent a reset link to',
                  style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(_emailCtrl.text.trim(),
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600, color: crimson),
                  textAlign: TextAlign.center),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.92, 0.92)),

        const SizedBox(height: 24),

        GradientButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Back to Sign In',
            style: GoogleFonts.poppins(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.6,
            ),
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 16),

        TextButton(
          onPressed: () => setState(() => _emailSent = false),
          child: Text("Didn't receive it? Try again",
              style: GoogleFonts.poppins(fontSize: 13, color: crimson, fontWeight: FontWeight.w700)),
        ),
      ],
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
