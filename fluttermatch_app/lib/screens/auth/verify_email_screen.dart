import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String redirectPath;
  const VerifyEmailScreen({super.key, required this.redirectPath});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isVerifying = true;
  bool _isSuccess = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    try {
      final dio = Dio();
      // Call the Laravel signed verification URL
      final url = ApiConstants.baseHost + widget.redirectPath;
      await dio.get(url);

      // ✅ Refresh the user state so AuthGate detects the verification
      await ref.read(authProvider.notifier).refreshUser();

      setState(() {
        _isSuccess = true;
        _message = 'Your email has been verified! You can now continue.';
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _message =
            'Verification failed. Link may be expired. Please request a new one.';
      });
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: _isVerifying
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      Text(
                        'Verifying your email...',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSuccess
                            ? Icons.mark_email_read_outlined
                            : Icons.error_outline_rounded,
                        size: 80,
                        color: _isSuccess ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isSuccess
                            ? 'Email Verified! ✅'
                            : 'Verification Failed ❌',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _message,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.popUntil(context, (r) => r.isFirst),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Go to Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
