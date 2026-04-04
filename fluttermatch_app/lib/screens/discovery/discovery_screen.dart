import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/discover_user_model.dart';
import '../../providers/discovery_provider.dart';
import '../../providers/match_provider.dart';
import '../matches/matches_screen.dart';
import 'widgets/profile_card.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  final _swiperController = CardSwiperController();
  bool _actionInProgress = false;

  @override
  void dispose() { _swiperController.dispose(); super.dispose(); }

  Future<void> _handleLike() async {
    if (_actionInProgress) return;
    setState(() => _actionInProgress = true);
    try {
      final result = await ref.read(discoveryProvider.notifier).likeTop();
      if (result['matched'] == true && mounted) _showMatchDialog(result['match_id']);
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _handleDislike() async {
    if (_actionInProgress) return;
    setState(() => _actionInProgress = true);
    try {
      await ref.read(discoveryProvider.notifier).dislikeTop();
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  void _showMatchDialog(int? matchId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MatchSheet(
        matchId: matchId,
        onSendMessage: () {
          ref.read(matchProvider.notifier).loadMatches();
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const MatchesScreen()));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(discoveryProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GlassBackground(child: SizedBox.expand()),
          const Positioned(top: -40, right: -40, child: GlassBlob(size: 180, opacity: 0.09)),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Glass Top Bar ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              primary,
                              Color.lerp(primary, Colors.pink, 0.5)!
                            ]),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite_rounded,
                              color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Lovi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: feedState.when(
                    loading: () => Center(
                        child: CircularProgressIndicator(color: primary)),
                    error: (e, _) => _ErrorState(
                        onRetry: () =>
                            ref.read(discoveryProvider.notifier).loadFeed()),
                    data: (users) => users.isEmpty
                        ? _EmptyState(
                            onRefresh: () =>
                                ref.read(discoveryProvider.notifier).loadFeed())
                        : _buildCardStack(users),
                  ),
                ),

                feedState.maybeWhen(
                  data: (users) => users.isNotEmpty
                      ? _buildActionButtons(primary)
                      : const SizedBox.shrink(),
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(height: 100), // space for glass nav bar
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack(List<DiscoverUserModel> users) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CardSwiper(
        controller: _swiperController,
        cardsCount: users.length,
        numberOfCardsDisplayed: users.length.clamp(1, 3),
        backCardOffset: const Offset(0, 24),
        scale: 0.95,
        padding: const EdgeInsets.symmetric(vertical: 8),
        onSwipe: (prev, current, direction) {
          if (direction == CardSwiperDirection.right) {
            _handleLike();
          } else if (direction == CardSwiperDirection.left) {
            _handleDislike();
          }
          return true;
        },
        cardBuilder: (ctx, index, percentX, percentY) {
          if (index >= users.length) return const SizedBox.shrink();
          return Stack(
            children: [
              ProfileCard(user: users[index]),
              if (index == 0 && percentX > 0.1)
                const Positioned(
                    top: 40, left: 20,
                    child: _SwipeLabel(label: 'LIKE', color: Colors.green)),
              if (index == 0 && percentX < -0.1)
                const Positioned(
                    top: 40, right: 20,
                    child: _SwipeLabel(label: 'NOPE', color: Colors.red)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _GlassActionBtn(
            onTap: () => _swiperController.swipe(CardSwiperDirection.left),
            icon: Icons.close_rounded, color: Colors.red.shade400, size: 58),
          _GlassActionBtn(
            onTap: () => _swiperController.swipe(CardSwiperDirection.right),
            icon: Icons.favorite_rounded, color: primary, size: 68),
          _GlassActionBtn(
            onTap: () {}, icon: Icons.star_rounded, color: Colors.amber, size: 50),
        ],
      ),
    );
  }
}

// ── Glass Action Button ────────────────────────────────────────────────────

class _GlassActionBtn extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final double size;
  const _GlassActionBtn({required this.onTap, required this.icon, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.10),
              border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
              boxShadow: [BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: Icon(icon, color: color, size: size * 0.46),
          ),
        ),
      ),
    );
  }
}

// ── Swipe Label ───────────────────────────────────────────────────────────────

class _SwipeLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SwipeLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: label == 'LIKE' ? -0.4 : 0.4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: BorderRadius.circular(8),
          color: color.withValues(alpha: 0.08),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w900,
                fontSize: 28, letterSpacing: 2)),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off_rounded, size: 80, color: onSurfaceVariant.withValues(alpha: 0.4)),
        const SizedBox(height: 16),
        Text('No more profiles nearby',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
        const SizedBox(height: 8),
        Text('Check back later or expand your distance',
            textAlign: TextAlign.center,
            style: TextStyle(color: onSurfaceVariant.withValues(alpha: 0.6), fontSize: 14)),
        const SizedBox(height: 24),
        GradientButton(
          onPressed: onRefresh,
          height: 48,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('Refresh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.wifi_off_rounded, size: 64, color: onSurfaceVariant.withValues(alpha: 0.4)),
        const SizedBox(height: 16),
        Text('Something went wrong', style: TextStyle(fontSize: 16, color: onSurfaceVariant)),
        const SizedBox(height: 16),
        GradientButton(
          onPressed: onRetry, height: 44,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('Try again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}

// ── Match Sheet ───────────────────────────────────────────────────────────────

class _MatchSheet extends StatelessWidget {
  final int? matchId;
  final VoidCallback onSendMessage;
  const _MatchSheet({this.matchId, required this.onSendMessage});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.4))),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            const Text('💞', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text("It's a Match!",
                style: TextStyle(
                    fontSize: 30, fontWeight: FontWeight.bold, color: primary)),
            const SizedBox(height: 8),
            Text('You and this person liked each other.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: onSurfaceVariant)),
            const SizedBox(height: 32),
            GradientButton(
              onPressed: () {
                Navigator.pop(context);
                onSendMessage();
              },
              child: const Text('Send a Message',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Keep Swiping',
                  style: TextStyle(color: onSurfaceVariant, fontSize: 15)),
            ),
          ]),
        ),
      ),
    );
  }
}
