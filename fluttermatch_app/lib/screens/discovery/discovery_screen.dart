import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  static const _pink = Color(0xFFE84393);
  final _swiperController = CardSwiperController();
  bool _actionInProgress = false;

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _handleLike() async {
    if (_actionInProgress) return;
    setState(() => _actionInProgress = true);
    try {
      final result = await ref.read(discoveryProvider.notifier).likeTop();
      if (result['matched'] == true && mounted) {
        _showMatchDialog(result['match_id']);
      }
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
          // Reload matches so the new one appears at the top
          ref.read(matchProvider.notifier).loadMatches();
          // Navigate to MatchesScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MatchesScreen()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(discoveryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: feedState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: _pink),
                ),
                error: (e, _) => _ErrorState(
                  onRetry: () {
                    ref.read(discoveryProvider.notifier).loadFeed();
                  },
                ),
                data: (users) => users.isEmpty
                    ? _EmptyState(
                        onRefresh: () {
                          ref.read(discoveryProvider.notifier).loadFeed();
                        },
                      )
                    : _buildCardStack(users),
              ),
            ),
            feedState.maybeWhen(
              data: (users) => users.isNotEmpty
                  ? _buildActionButtons()
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, color: _pink, size: 28),
          const SizedBox(width: 8),
          const Text(
            'FlutterMatch',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
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

              // Like overlay
              if (index == 0 && percentX > 0.1)
                Positioned(
                  top: 40,
                  left: 20,
                  child: _SwipeLabel(label: 'LIKE', color: Colors.green),
                ),
              // Nope overlay
              if (index == 0 && percentX < -0.1)
                Positioned(
                  top: 40,
                  right: 20,
                  child: _SwipeLabel(label: 'NOPE', color: Colors.red),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionBtn(
            onTap: () => _swiperController.swipe(CardSwiperDirection.left),
            icon: Icons.close_rounded,
            color: Colors.red.shade400,
            size: 58,
          ),
          _ActionBtn(
            onTap: () => _swiperController.swipe(CardSwiperDirection.right),
            icon: Icons.favorite_rounded,
            color: _pink,
            size: 68,
          ),
          _ActionBtn(
            onTap: () {},
            icon: Icons.star_rounded,
            color: Colors.amber,
            size: 50,
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────

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
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final double size;

  const _ActionBtn({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.48),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No more profiles nearby',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later or expand your\ndistance in preferences',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE84393),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE84393),
              foregroundColor: Colors.white,
            ),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _MatchSheet extends StatelessWidget {
  final int? matchId;
  final VoidCallback onSendMessage;

  static const _pink = Color(0xFFE84393);

  const _MatchSheet({this.matchId, required this.onSendMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💞', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            "It's a Match!",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: _pink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You and this person liked each other.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close sheet first
                onSendMessage(); // then navigate
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Send a Message',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Keep Swiping',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
