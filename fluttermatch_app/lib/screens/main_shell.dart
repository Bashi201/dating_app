import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/match_provider.dart';
import '../providers/profile_provider.dart';
import 'discovery/discovery_screen.dart';
import 'matches/matches_screen.dart';
import 'profile/profile_edit_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DiscoveryScreen(),
      const MatchesScreen(),
      const _ProfileTab(),
    ];

    final totalUnread = ref
        .watch(matchProvider)
        .maybeWhen(
          data: (matches) => matches.fold(0, (sum, m) => sum + m.unreadCount),
          orElse: () => 0,
        );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true, // body goes behind glass nav bar
      body: IndexedStack(index: _tab, children: screens),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.60),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.85),
                  width: 1.0,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              backgroundColor: Colors.transparent,
              elevation: 0,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: 'Discover',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: totalUnread > 0,
                    label: Text('$totalUnread'),
                    child: const Icon(Icons.favorite_border_rounded),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: totalUnread > 0,
                    label: Text('$totalUnread'),
                    child: const Icon(Icons.favorite_rounded),
                  ),
                  label: 'Matches',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final profile = ref.watch(profileProvider).valueOrNull;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    // Calculate a mock completion percentage based on filled data
    int completion = 20; // Base completion
    if (profile != null) {
      if (profile.bio?.isNotEmpty == true) completion += 20;
      if (profile.photos.isNotEmpty) completion += 20;
      if (profile.interests.isNotEmpty) completion += 20;
      if (profile.city?.isNotEmpty == true) completion += 20;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GlassBackground(child: SizedBox.expand()),

          // Decorative blobs for dynamic background
          const Positioned(top: -40, right: -40, child: GlassBlob(size: 200, opacity: 0.12)),
          const Positioned(top: 250, left: -60, child: GlassBlob(size: 150, opacity: 0.08)),

          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: Column(
                      children: [
                        // ── Big Profile Avatar ─────────────────────────────────
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer ring indicating profile completion
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CircularProgressIndicator(
                                value: completion / 100,
                                strokeWidth: 3,
                                color: primary,
                                backgroundColor: primary.withValues(alpha: 0.1),
                              ),
                            ),
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primary.withValues(alpha: 0.1),
                                image: profile?.primaryPhotoUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(profile!.primaryPhotoUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: profile?.primaryPhotoUrl == null
                                  ? Icon(Icons.person_rounded, size: 60, color: primary)
                                  : null,
                            ),
                            // Completion Badge
                            Positioned(
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Text(
                                  '$completion% COMPLETE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // User Name & Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user?.name ?? 'User',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                            ),
                            if (profile?.age != null)
                              Text(
                                ', ${profile?.age}',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: onSurfaceVariant,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            const SizedBox(width: 4),
                            Icon(Icons.verified_rounded, color: primary, size: 20),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (profile?.city?.isNotEmpty == true)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on_rounded, size: 14, color: onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                profile!.city!,
                                style: TextStyle(color: onSurfaceVariant, fontSize: 13),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Action Buttons Row ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ProfileActionButton(
                          icon: Icons.settings_rounded,
                          label: 'Settings',
                          color: Colors.blueGrey,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const SettingsScreen())),
                        ),
                        _ProfileActionButton(
                          icon: Icons.edit_rounded,
                          label: 'Edit Info',
                          color: primary,
                          scale: 1.15, // Make primary action slightly bigger
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
                        ),
                        _ProfileActionButton(
                          icon: Icons.safety_check_rounded,
                          label: 'Safety',
                          color: Colors.blue,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Safety Center coming soon!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Premium / Boost Card (Visual Flair) ─────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            primary,
                            Color.lerp(primary, Colors.orange, 0.4)!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Glass overlay effect
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: CustomPaint(
                                painter: _GlassShinePainter(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 32),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Get Lovi+',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'See who likes you and get more matches instantly!',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

class _ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double scale;

  const _ProfileActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Transform.scale(
            scale: scale,
            child: GlassCard(
              borderRadius: 30, // Circular
              padding: const EdgeInsets.all(16),
              borderColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color, size: 24),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// Gives the premium card a subtle "glass shine" slash
class _GlassShinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.4, 0)
      ..lineTo(size.width * 0.6, size.height)
      ..lineTo(size.width * 0.2, size.height)
      ..close();
      
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
