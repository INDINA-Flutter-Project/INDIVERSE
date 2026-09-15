import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/widget/empty_state.dart';
import '../../models/playtester_interest.dart';
import '../../service/playtest_interest_service.dart';

class PlaytestersScreen extends StatefulWidget {
  const PlaytestersScreen({super.key});

  @override
  State<PlaytestersScreen> createState() => _PlaytestersScreenState();
}

class _PlaytestersScreenState extends State<PlaytestersScreen> {
  late Future<List<PlaytesterInterest>> _interestsFuture;

  @override
  void initState() {
    super.initState();
    _interestsFuture = _load();
  }

  Future<List<PlaytesterInterest>> _load() async {
    final developerId = Supabase.instance.client.auth.currentUser?.id;
    if (developerId == null) return const <PlaytesterInterest>[];

    try {
      return await PlaytestInterestService().getInterestsForDeveloper(
        developerId,
      );
    } catch (e, st) {
      debugPrint('getInterestsForDeveloper failed: $e\n$st');
      if (e is PostgrestException) {
        debugPrint(
          'PLAYTEST DEBUG postgrest message=${e.message} code=${e.code} '
          'details=${e.details} hint=${e.hint}',
        );
      }
      rethrow;
    }
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _interestsFuture = future);
    try {
      await future;
    } catch (_) {
      // Already logged inside _load() and will be surfaced by FutureBuilder
      // (which independently watches _interestsFuture) — swallow here so
      // callers that discard this Future (the retry button, RefreshIndicator)
      // never see an unhandled Future error.
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<PlaytesterInterest>>(
        future: _interestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _ScrollableCenter(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ScrollableCenter(child: _PlaytestersError(onRetry: _refresh));
          }

          final interests = snapshot.data ?? const <PlaytesterInterest>[];

          if (interests.isEmpty) {
            return const _ScrollableCenter(
              child: EmptyState(
                icon: Icons.emoji_people_outlined,
                title: 'No playtesters yet',
                message:
                    'Players interested in testing your upcoming games '
                    'will appear here.',
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            children: [
              const Text('Playtesters', style: AppTextStyles.pageTitle),
              const SizedBox(height: 6),
              const Text(
                'Players interested in testing your games.',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < interests.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _PlaytesterCard(interest: interests[i]),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Keeps [RefreshIndicator]'s pull gesture working while the body is a
/// single centered widget (loading/empty/error) rather than a real list.
class _ScrollableCenter extends StatelessWidget {
  const _ScrollableCenter({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: Center(child: child),
            ),
          ],
        );
      },
    );
  }
}

class _PlaytesterCard extends StatelessWidget {
  const _PlaytesterCard({required this.interest});

  final PlaytesterInterest interest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primaryContainer,
            child: Icon(Icons.person_outline_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  interest.playerName ?? 'Unnamed player',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(interest.playerEmail, style: AppTextStyles.bodyMuted),
                const SizedBox(height: 8),
                Text(
                  'Interested in: ${interest.gameName}',
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: AppColors.primary,
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

class _PlaytestersError extends StatelessWidget {
  const _PlaytestersError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_rounded, size: 48),
        const SizedBox(height: 16),
        const Text(
          'Unable to load playtesters',
          style: TextStyle(fontFamily: 'Michroma', fontSize: 18),
        ),
        const SizedBox(height: 8),
        const Text(
          'Check your connection and try again.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Tomorrow',
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    ),
  );
}
