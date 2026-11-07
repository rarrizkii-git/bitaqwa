import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dhikr/presentation/dhikr_page.dart';
import '../../features/dua/presentation/dua_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/prayer/presentation/prayer_page.dart';
import '../../features/qibla/presentation/qibla_page.dart';
import '../../features/quran/presentation/quran_page.dart';
import '../../features/quran/presentation/surah_detail_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../shared/layout/navbar.dart';
import '../../shared/layout/page_scaffold.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/islamic_art.dart';

/// The site navigation lives in a shell so it stays fixed while each page
/// manages its own scroll position and footer.
class _SiteShell extends StatelessWidget {
  const _SiteShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            const SiteNavbar(),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) => _SiteShell(child: child),
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage<void>(
            child: HomePage(),
          ),
        ),
        GoRoute(
          path: '/jadwal-shalat',
          pageBuilder: (context, state) => const NoTransitionPage<void>(
            child: PrayerPage(),
          ),
        ),
        GoRoute(
          path: '/quran',
          pageBuilder: (context, state) => const NoTransitionPage<void>(
            child: QuranPage(),
          ),
          routes: <RouteBase>[
            GoRoute(
              path: ':number',
              pageBuilder: (context, state) {
                final number = int.tryParse(
                      state.pathParameters['number'] ?? '',
                    ) ??
                    0;
                return NoTransitionPage<void>(
                  child: SurahDetailPage(surahNumber: number),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/doa',
          pageBuilder: (context, state) => const NoTransitionPage<void>(
            child: DuaPage(),
          ),
        ),
        GoRoute(
          path: '/zikir',
          pageBuilder: (context, state) => const NoTransitionPage<void>(
            child: DhikrPage(),
          ),
        ),
        GoRoute(
          path: '/kiblat',
          pageBuilder: (context, state) => const NoTransitionPage<void>(
            child: QiblaPage(),
          ),
        ),
        GoRoute(
          path: '/pengaturan',
          pageBuilder: (context, state) => const NoTransitionPage<void>(
            child: SettingsPage(),
          ),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => _NotFoundPage(location: state.uri.path),
);

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return _SiteShell(
      child: PageScaffold(
        child: Column(
          children: <Widget>[
            PageHeader(
              eyebrow: 'Halaman tidak ditemukan',
              title: 'Jalan ini belum ada.',
              description:
                  'Alamat "$location" tidak tersedia di Bitaqwa. Kembali ke beranda atau '
                  'lanjutkan ke salah satu bagian utama.',
              action: const RotatingStar(size: 110, opacity: 0.28),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 56,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: <Widget>[
                    const OrnamentDivider(width: 200),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        AppButton(
                          label: 'Kembali ke beranda',
                          icon: Icons.home_outlined,
                          onPressed: () => context.go('/'),
                        ),
                        AppButton(
                          label: "Buka Al-Qur'an",
                          icon: Icons.menu_book_outlined,
                          variant: AppButtonVariant.secondary,
                          onPressed: () => context.go('/quran'),
                        ),
                        AppButton(
                          label: 'Jadwal shalat',
                          icon: Icons.access_time_rounded,
                          variant: AppButtonVariant.secondary,
                          onPressed: () => context.go('/jadwal-shalat'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
