import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../profile_setup/profile_setup_screen.dart';

class VerifyEmailStatusScreen extends ConsumerStatefulWidget {
  const VerifyEmailStatusScreen({super.key});

  @override
  ConsumerState<VerifyEmailStatusScreen> createState() =>
      _VerifyEmailStatusScreenState();
}

class _VerifyEmailStatusScreenState
    extends ConsumerState<VerifyEmailStatusScreen> {
  bool _isResending = false;
  bool _isChecking = false;

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      await ref.read(authProvider.notifier).resendVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification link resent! 📧')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);
    try {
      await ref.read(authProvider.notifier).refreshUser();
      if (!mounted) return;
      final user = ref.read(authProvider).asData?.value;
      if (user != null && user.emailVerified) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Email not verified yet. Please click the link in your inbox first.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ));
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).asData?.value;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GlassBackground(child: SizedBox.expand()),
          const Positioned(top: -50, right: -50, child: GlassBlob(size: 200, opacity: 0.10)),
          const Positioned(bottom: 80, left: -60, child: GlassBlob(size: 160, opacity: 0.08)),

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: GlassCard(
                      borderRadius: 12,
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        icon: Icon(Icons.logout_rounded, color: primary),
                        onPressed: () => ref.read(authProvider.notifier).logout(),
                        tooltip: 'Logout',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ── Envelope icon ─────────────────────────────────
                          GlassCard(
                            borderRadius: 28,
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child:
                                      Icon(Icons.email_outlined, size: 46, color: primary),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Verify your email',
                                  style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: onSurface),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'We sent a verification link to:',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: onSurfaceVariant),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? '',
                                  style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: primary),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ).animate().fadeIn().slideY(begin: -0.15, end: 0),

                          const SizedBox(height: 20),

                          // ── Info box ───────────────────────────────────────
                          GlassCard(
                            borderRadius: 16,
                            padding: const EdgeInsets.all(16),
                            borderColor: primary.withValues(alpha: 0.25),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    color: primary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Open the verification link in your browser, then tap \"I've Verified My Email\" below.",
                                    style: GoogleFonts.poppins(
                                        fontSize: 13, color: onSurfaceVariant),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 200.ms),

                          const SizedBox(height: 24),

                          GradientButton(
                            onPressed: _isChecking ? null : _checkVerification,
                            child: _isChecking
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5))
                                : const Text("I've Verified My Email",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                          ).animate().fadeIn(delay: 300.ms),

                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: _isResending ? null : _resend,
                            child: _isResending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2))
                                : Text('Resend verification link',
                                    style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
