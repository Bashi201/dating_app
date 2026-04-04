import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../profile/profile_edit_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
          const GlassBackground(child: SizedBox.expand()),

          // Decorative blobs
          Positioned(top: -60, right: -50, child: GlassBlob(size: 200, opacity: 0.10)),
          Positioned(bottom: 160, left: -60, child: GlassBlob(size: 150, opacity: 0.08)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── App Bar ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: GlassCard(
                            borderRadius: 12,
                            padding: const EdgeInsets.all(10),
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 18, color: primary),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 8),

                  // ── Account Section ────────────────────────────────────────
                  _SectionLabel(label: 'Account', color: onSurfaceVariant),
                  const SizedBox(height: 10),

                  GlassCard(
                    borderRadius: 18,
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.person_outline_rounded,
                          iconColor: primary,
                          title: 'Edit Profile',
                          subtitle: 'Update your photos, bio & interests',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfileEditScreen()),
                          ),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.15, end: 0),

                  const SizedBox(height: 24),

                  // ── Appearance Section ─────────────────────────────────────
                  _SectionLabel(label: 'Appearance', color: onSurfaceVariant),
                  const SizedBox(height: 10),

                  GlassCard(
                    borderRadius: 18,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.indigo.withValues(alpha: 0.25)
                                  : Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isDark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              color: isDark ? Colors.indigo.shade300 : Colors.amber.shade700,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dark Mode',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: onSurface,
                                  ),
                                ),
                                Text(
                                  isDark ? 'Switch to light mode' : 'Switch to dark mode',
                                  style: TextStyle(
                                      fontSize: 12, color: onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: themeMode == ThemeMode.dark,
                            onChanged: (_) =>
                                ref.read(themeModeProvider.notifier).toggle(),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15, end: 0),

                  const SizedBox(height: 24),

                  // ── About Section ──────────────────────────────────────────
                  _SectionLabel(label: 'About', color: onSurfaceVariant),
                  const SizedBox(height: 10),

                  GlassCard(
                    borderRadius: 18,
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.favorite_rounded,
                          iconColor: primary,
                          title: 'Lovi',
                          subtitle: 'Version 1.0.0',
                          onTap: null,
                          showDivider: false,
                          trailing: const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15, end: 0),

                  const SizedBox(height: 24),

                  // ── Logout ─────────────────────────────────────────────────
                  GlassCard(
                    borderRadius: 18,
                    borderColor: Colors.red.withValues(alpha: 0.25),
                    child: _SettingsTile(
                      icon: Icons.logout_rounded,
                      iconColor: Colors.red.shade400,
                      title: 'Log Out',
                      subtitle: 'Sign out of your account',
                      titleColor: Colors.red.shade400,
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Log out'),
                            content: const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Log out',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          if (context.mounted) {
                            Navigator.of(context).pop(); // pop SettingsScreen
                          }
                          ref.read(authProvider.notifier).logout();
                        }
                      },
                      showDivider: false,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.15, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── Settings Tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final VoidCallback? onTap;
  final bool showDivider;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.showDivider,
    this.titleColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? onSurface,
                    ),
                  ),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    color: onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
