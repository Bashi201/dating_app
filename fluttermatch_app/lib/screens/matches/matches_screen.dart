import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/match_model.dart';
import '../../providers/match_provider.dart';
import '../chat/chat_screen.dart';

class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GlassBackground(child: SizedBox.expand()),
          const Positioned(top: -30, left: -50, child: GlassBlob(size: 160, opacity: 0.08)),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Glass App Bar ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        Text(
                          'Matches',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold, color: onSurface),
                        ),
                        const Spacer(),
                        Icon(Icons.favorite_rounded, color: primary, size: 22),
                      ],
                    ),
                  ),
                ),

                // ── List ─────────────────────────────────────────────────────
                Expanded(
                  child: state.when(
                    loading: () => Center(
                        child: CircularProgressIndicator(color: primary)),
                    error: (e, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Failed to load matches',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 12),
                          GradientButton(
                            onPressed: () =>
                                ref.read(matchProvider.notifier).loadMatches(),
                            height: 44,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text('Retry',
                                  style: TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          )
                        ],
                      ),
                    ),
                    data: (matches) => matches.isEmpty
                        ? _EmptyState()
                        : RefreshIndicator(
                            color: primary,
                            onRefresh: () =>
                                ref.read(matchProvider.notifier).loadMatches(),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                              itemCount: matches.length,
                              itemBuilder: (ctx, i) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _MatchTile(match: matches[i]),
                              ),
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

// ── Match Tile ─────────────────────────────────────────────────────────────────

class _MatchTile extends ConsumerWidget {
  final MatchModel match;
  const _MatchTile({required this.match});

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().toUtc().difference(dt.toUtc());
    if (diff.inMinutes < 1 && diff.inMinutes >= 0) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final other = match.otherUser;
    final last = match.lastMessage;
    final unread = match.unreadCount;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return GlassCard(
      borderRadius: 18,
      child: InkWell(
        onTap: () {
          ref.read(matchProvider.notifier).clearUnread(match.id);
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChatScreen(match: match)));
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: unread > 0
                      ? LinearGradient(
                          colors: [primary, Color.lerp(primary, Colors.pink, 0.5)!])
                      : null,
                  color: unread > 0 ? null : Colors.transparent,
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: primary.withValues(alpha: 0.12),
                  backgroundImage: other.photoUrl != null
                      ? NetworkImage(other.photoUrl!)
                      : null,
                  child: other.photoUrl == null
                      ? Icon(Icons.person_rounded, color: primary)
                      : null,
                ),
              ),
              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      other.name,
                      style: TextStyle(
                        fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w600,
                        fontSize: 15, color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    last != null
                        ? Text(
                            last.isMine ? 'You: ${last.body}' : last.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: unread > 0 ? onSurface : onSurfaceVariant,
                              fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13,
                            ),
                          )
                        : Text('Say hello! 👋',
                            style: TextStyle(
                              color: onSurfaceVariant.withValues(alpha: 0.7),
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
                            )),
                  ],
                ),
              ),

              // Time + badge
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _timeAgo(last?.createdAt ?? match.matchedAt),
                    style: TextStyle(
                      color: unread > 0 ? primary : onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  if (unread > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary, Color.lerp(primary, Colors.pink, 0.4)!]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$unread',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.favorite_border_rounded, size: 72,
            color: onSurfaceVariant.withValues(alpha: 0.35)),
        const SizedBox(height: 16),
        Text('No matches yet',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
        const SizedBox(height: 8),
        Text('Keep swiping to find your match!',
            style: TextStyle(
                color: onSurfaceVariant.withValues(alpha: 0.6), fontSize: 14)),
      ]),
    );
  }
}
