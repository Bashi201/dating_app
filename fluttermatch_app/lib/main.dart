import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/auth/verify_email_status_screen.dart';
import 'screens/main_shell.dart';
import 'screens/profile_setup/profile_setup_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'] ?? '';
        final email = state.uri.queryParameters['email'] ?? '';
        return ResetPasswordScreen(token: token, email: email);
      },
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) {
        final redirect = state.uri.queryParameters['redirect'] ?? '';
        return VerifyEmailScreen(redirectPath: redirect);
      },
    ),
    GoRoute(path: '/', builder: (context, state) => const AuthGate()),
  ],
);

void main() {
  usePathUrlStrategy();
  runApp(const ProviderScope(child: LoviApp()));
}

// ─── Root App ─────────────────────────────────────────────────────────────────

class LoviApp extends ConsumerWidget {
  const LoviApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Lovi',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
    );
  }
}

// ─── Auth Gate ────────────────────────────────────────────────────────────────

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const LoginScreen(),
      data: (user) {
        if (user == null) return const LoginScreen();
        if (user.emailVerified == false) return const VerifyEmailStatusScreen();
        if (user.profileComplete == false) return const ProfileSetupScreen();
        return const MainShell();
      },
    );
  }
}
