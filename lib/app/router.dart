import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lilt/core/providers/repository_providers.dart';
import 'package:lilt/features/home/home_screen.dart';
import 'package:lilt/features/matchup/matchup_screen.dart';
import 'package:lilt/features/name_detail/name_detail_screen.dart';
import 'package:lilt/features/pool_config/pool_config_screen.dart';
import 'package:lilt/features/results/couple_results_screen.dart';
import 'package:lilt/features/results/solo_results_screen.dart';
import 'package:lilt/features/settings/settings_screen.dart';
import 'package:lilt/features/shortlist/shortlist_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

/// Hands the phone from Partner A to Partner B. Everything above Home is
/// popped first, so nothing of A's (ranking or results) sits in the back
/// stack beneath B's matchup: a redirect guards a route when it is pushed,
/// never when it is popped back to.
void handOffToPartner(BuildContext context, String partnerASessionId) {
  final router = GoRouter.of(context);
  while (router.canPop()) {
    router.pop();
  }
  router.push('/pool-config?partnerB=1&partnerA=$partnerASessionId');
}

/// Peeking prevention for one partner's own results: a locked session that
/// belongs to a couple opens only once BOTH partners have finished.
Future<String?> _soloResultsGuard(
    BuildContext context, GoRouterState state) async {
  final id = state.pathParameters['sessionId'];
  if (id == null) return '/';
  final repo = ProviderScope.containerOf(context).read(sessionRepositoryProvider);
  final session = await repo.getSession(id);
  final partnerId = session?.partnerSessionId;
  if (session == null || partnerId == null || !session.resultsLocked) {
    return null;
  }
  final partner = await repo.getSession(partnerId);
  if (partner == null) return null; // partner deleted: nobody left to peek
  return session.isComplete && partner.isComplete ? null : '/';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/pool-config',
        builder: (context, state) {
          final isPartnerB = state.uri.queryParameters['partnerB'] == '1';
          final isCoupleFlow = state.uri.queryParameters['couple'] == '1';
          final partnerASessionId = state.uri.queryParameters['partnerA'];
          return PoolConfigScreen(
            isPartnerB: isPartnerB,
            isCoupleFlow: isCoupleFlow,
            partnerASessionId: partnerASessionId,
          );
        },
      ),
      GoRoute(
        path: '/matchup/:sessionId',
        builder: (context, state) => MatchupScreen(
          sessionId: state.pathParameters['sessionId']!,
          partnerASessionId: state.uri.queryParameters['partnerA'],
        ),
      ),
      GoRoute(
        path: '/results/solo/:sessionId',
        redirect: _soloResultsGuard,
        builder: (context, state) => SoloResultsScreen(
          sessionId: state.pathParameters['sessionId']!,
        ),
      ),
      GoRoute(
        path: '/results/couple',
        redirect: (context, state) async {
          // Peeking prevention: both sessions must be locked+complete.
          final a = state.uri.queryParameters['a'];
          final b = state.uri.queryParameters['b'];
          if (a == null || b == null) return '/';
          final container = ProviderScope.containerOf(context);
          final repo = container.read(sessionRepositoryProvider);
          final sessionA = await repo.getSession(a);
          final sessionB = await repo.getSession(b);
          if (sessionA == null || sessionB == null) return '/';
          final bothReady = sessionA.isComplete &&
              sessionA.resultsLocked &&
              sessionB.isComplete &&
              sessionB.resultsLocked;
          if (!bothReady) return '/';
          return null;
        },
        builder: (context, state) => CoupleResultsScreen(
          sessionAId: state.uri.queryParameters['a']!,
          sessionBId: state.uri.queryParameters['b']!,
        ),
      ),
      GoRoute(
        path: '/name/:nameId',
        builder: (context, state) => NameDetailScreen(
          nameId: state.pathParameters['nameId']!,
          sessionAId: state.uri.queryParameters['a'],
          sessionBId: state.uri.queryParameters['b'],
        ),
      ),
      GoRoute(
        path: '/shortlist',
        builder: (context, state) => const ShortlistScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(),
      body: OhErrorState(
        title: 'This page isn’t here',
        message: 'The link may be out of date. Your names and sessions '
            'are safe.',
        error: state.error,
        icon: Icons.explore_off_outlined,
        retryLabel: 'Back to your sessions',
        onRetry: () => context.go('/'),
      ),
    ),
  );
});
