import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/main_shell.dart';
import 'screens/profile_setup/profile_setup_screen.dart';

// ─── Router ───────────────────────────────────────────────────────────────────
// /reset-password → PUBLIC — no auth check, opened from email link
// /               → AuthGate — decides login / profile setup / main app

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // ✅ Must be FIRST — before AuthGate catches everything
    // Handles: http://localhost:8080/reset-password?token=xxx&email=yyy
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'] ?? '';
        final email = state.uri.queryParameters['email'] ?? '';
        return ResetPasswordScreen(token: token, email: email);
      },
    ),

    // All other routes go through AuthGate
    GoRoute(path: '/', builder: (context, state) => const AuthGate()),
  ],
);

void main() {
  // Removes # from Flutter Web URLs
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

      // go_router handles all URL routing including /reset-password
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

        // Logged in but profile not complete → profile setup
        if (user.profileComplete == false) return const ProfileSetupScreen();

        // Fully logged in → main app
        return const MainShell();
      },
    );
  }
}
