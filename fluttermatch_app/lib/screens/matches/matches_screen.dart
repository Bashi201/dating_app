import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/match_model.dart';
import '../../providers/match_provider.dart';
import '../chat/chat_screen.dart';

class MatchesScreen extends ConsumerWidget {
  static const _pink = Color(0xFFE84393);

  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Matches',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: state.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _pink)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load matches',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(matchProvider.notifier).loadMatches(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pink,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (matches) => matches.isEmpty
            ? _EmptyState()
            : RefreshIndicator(
                color: _pink,
                onRefresh: () => ref.read(matchProvider.notifier).loadMatches(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: matches.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    indent: 80,
                    color: Colors.grey.shade100,
                  ),
                  itemBuilder: (ctx, i) => _MatchTile(match: matches[i]),
                ),
              ),
      ),
    );
  }
}

class _MatchTile extends ConsumerWidget {
  final MatchModel match;

  static const _pink = Color(0xFFE84393);

  const _MatchTile({required this.match});

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
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

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: () {
        ref.read(matchProvider.notifier).clearUnread(match.id);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatScreen(match: match)),
        );
      },
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: const Color(0xFFFFE0F0),
        backgroundImage: other.photoUrl != null
            ? NetworkImage(other.photoUrl!)
            : null,
        child: other.photoUrl == null
            ? const Icon(Icons.person, color: _pink)
            : null,
      ),
      title: Text(
        other.name,
        style: TextStyle(
          fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: last != null
          ? Text(
              last.isMine ? 'You: ${last.body}' : last.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unread > 0
                    ? const Color(0xFF1A1A2E)
                    : Colors.grey.shade500,
                fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            )
          : Text(
              'Say hello! 👋',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _timeAgo(last?.createdAt ?? match.matchedAt),
            style: TextStyle(
              color: unread > 0 ? _pink : Colors.grey.shade400,
              fontSize: 11,
            ),
          ),
          if (unread > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _pink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No matches yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep swiping to find your match!',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
