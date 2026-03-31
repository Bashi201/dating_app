import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/auth/verify_email_status_screen.dart';
import 'screens/main_shell.dart';
import 'screens/profile_setup/profile_setup_screen.dart';

// ─── Router ───────────────────────────────────────────────────────────────────
// Public routes must be FIRST — before AuthGate catches everything
// /reset-password  → ResetPasswordScreen  (from reset email link)
// /verify-email    → VerifyEmailScreen    (from verify email link)
// /                → AuthGate             (login / profile setup / main app)

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // ✅ Password reset — opened from reset email link
    // http://localhost:8080/reset-password?token=xxx&email=yyy
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'] ?? '';
        final email = state.uri.queryParameters['email'] ?? '';
        return ResetPasswordScreen(token: token, email: email);
      },
    ),

    // ✅ Email verification — opened from verify email link
    // http://localhost:8080/verify-email?redirect=/api/email/verify/1/hash...
    GoRoute(
      path: '/verify-email',
      builder: (context, state) {
        final redirect = state.uri.queryParameters['redirect'] ?? '';
        return VerifyEmailScreen(redirectPath: redirect);
      },
    ),

    // All other routes go through AuthGate
    GoRoute(path: '/', builder: (context, state) => const AuthGate()),
  ],
);

void main() {
  // Removes # from Flutter Web URLs so routes match correctly
  // Without: http://localhost:8080/#/reset-password  ← won't match
  // With:    http://localhost:8080/reset-password    ← matches ✅
  usePathUrlStrategy();
  runApp(const ProviderScope(child: FlutterMatchApp()));
}

// ─── Root App ─────────────────────────────────────────────────────────────────

class FlutterMatchApp extends StatelessWidget {
  const FlutterMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FlutterMatch',
      debugShowCheckedModeBanner: false,

      // go_router handles all URL routing
      routerConfig: _router,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE84393)),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
    );
  }
}

// ─── Auth Gate ────────────────────────────────────────────────────────────────
// Watches authProvider and routes user to correct screen:
//   loading                         → spinner
//   error                           → LoginScreen
//   data(null)                      → LoginScreen  (not logged in)
//   data(user) + incomplete profile → ProfileSetupScreen
//   data(user) + complete profile   → MainShell

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      // App is checking token on launch
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      // Token invalid / network error → go to login
      error: (_, __) => const LoginScreen(),

      // Token checked — decide where to go
      data: (user) {
        // No user / logged out → login screen
        if (user == null) return const LoginScreen();

        // 🟢 Check if email is verified
        if (user.emailVerified == false) {
          return const VerifyEmailStatusScreen();
        }

        // Logged in but profile not complete → profile setup
        if (user.profileComplete == false) return const ProfileSetupScreen();

        // Fully logged in → main app
        return const MainShell();
      },
    );
  }
}
