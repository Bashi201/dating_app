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
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GlassBackground(child: SizedBox.expand()),
          Positioned(top: -60, right: -40, child: GlassBlob(size: 200, opacity: 0.11)),
          Positioned(bottom: 100, left: -50, child: GlassBlob(size: 150, opacity: 0.09)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: GlassCard(
                        borderRadius: 12,
                        padding: const EdgeInsets.all(10),
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: primary),
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 32),

                  if (_emailSent)
                    _successView(primary, onSurface, onSurfaceVariant)
                  else
                    _emailView(primary, onSurface, onSurfaceVariant),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailView(Color primary, Color onSurface, Color onSurfaceVariant) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.lock_reset_rounded, size: 28, color: primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Forgot password?',
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.w700, color: onSurface)),
                      const SizedBox(height: 4),
                      Text("We'll send a reset link to your email.",
                          style: GoogleFonts.poppins(fontSize: 13, color: onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.15, end: 0),

          const SizedBox(height: 24),

          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            child: TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter a valid email';
                return null;
              },
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15, end: 0),

          const SizedBox(height: 24),

          GradientButton(
            onPressed: _isLoading ? null : _sendResetLink,
            child: _isLoading
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('Send Reset Link',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _successView(Color primary, Color onSurface, Color onSurfaceVariant) {
    return Column(
      children: [
        GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined, size: 40, color: Colors.green),
              ),
              const SizedBox(height: 20),
              Text('Check your email',
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.w700, color: onSurface)),
              const SizedBox(height: 8),
              Text('We sent a reset link to',
                  style: GoogleFonts.poppins(fontSize: 14, color: onSurfaceVariant),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(_emailCtrl.text.trim(),
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600, color: primary),
                  textAlign: TextAlign.center),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),

        const SizedBox(height: 24),

        GradientButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Sign In',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 16),

        TextButton(
          onPressed: () => setState(() => _emailSent = false),
          child: Text("Didn't receive it? Try again",
              style: GoogleFonts.poppins(fontSize: 13, color: primary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
