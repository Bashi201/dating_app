import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/discover_user_model.dart';
import '../../../screens/report/report_sheet.dart';
import '../../../services/safety_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../providers/discovery_provider.dart';

class ProfileCard extends ConsumerWidget {
  final DiscoverUserModel user;
  const ProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.grey.shade200,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Photo ───────────────────────────────────────────
            user.primaryPhotoUrl != null
                ? Image.network(user.primaryPhotoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),

            // ── Subtle top gradient for menu contrast ───────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.0, 0.15, 0.45, 0.70, 1.0],
                  ),
                ),
              ),
            ),

            // ── More actions menu (top right) ───────────────────
            Positioned(
              top: 14,
              right: 14,
              child: Theme(
                data: Theme.of(context).copyWith(cardColor: Colors.white),
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25), width: 1),
                    ),
                    child: const Icon(Icons.more_vert,
                        color: Colors.white, size: 18),
                  ),
                  onSelected: (val) {
                    if (val == 'report') {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => ReportSheet(userId: user.id, userName: user.name),
                      );
                    } else if (val == 'block') {
                      _confirmBlock(context, ref);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(children: [
                        Icon(Icons.flag_outlined, color: Colors.orange, size: 20),
                        SizedBox(width: 10),
                        Text('Report User', style: TextStyle(fontSize: 14)),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'block',
                      child: Row(children: [
                        Icon(Icons.block, color: Colors.red, size: 20),
                        SizedBox(width: 10),
                        Text('Block User',
                            style: TextStyle(color: Colors.red, fontSize: 14)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),

            // ── Info area (bottom) ──────────────────────────────
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.age != null ? '${user.name}, ${user.age}' : user.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black45)]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (user.city != null || user.distanceKm != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(children: [
                        const Icon(Icons.location_on_rounded,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          [
                            if (user.city != null) user.city!,
                            if (user.distanceKm != null)
                              '${user.distanceKm!.toStringAsFixed(0)} km away',
                          ].join(' · '),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ]),
                    ),

                  if (user.bio != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        user.bio!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // Glass interest chips
                  if (user.interests.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: user.interests.take(4).map((interest) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.45)),
                            ),
                            child: Text(interest,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11,
                                    fontWeight: FontWeight.w500)),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey.shade300,
        child: const Center(
            child: Icon(Icons.person, size: 80, color: Colors.white)),
      );

  Future<void> _confirmBlock(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Block ${user.name}?'),
        content: const Text(
            'They won\'t be able to see your profile or message you. This action is mutual.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Block', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final service = SafetyService(ref.read(dioProvider));
        await service.blockUser(user.id);
        if (ref.context.mounted) ref.read(discoveryProvider.notifier).loadFeed();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${user.name} has been blocked.'),
            backgroundColor: Colors.grey.shade800,
          ));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to block. Try again.'),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }
}
