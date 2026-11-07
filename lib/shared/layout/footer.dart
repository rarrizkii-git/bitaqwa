import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/bitaqwa_palette.dart';
import '../../core/utils/responsive.dart';
import '../widgets/brand.dart';
import '../widgets/islamic_art.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final background =
        context.isDarkMode ? palette.surfaceAlt : palette.primaryDeep;
    const foreground = Color(0xFFF4F0E6);
    const muted = Color(0xBFF4F0E6);

    return Container(
      decoration: BoxDecoration(
        color: background,
        border: Border(
          top: BorderSide(color: palette.gold.withValues(alpha: 0.35)),
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IslamicPattern(
              color: const Color(0xFFF4F0E6),
              opacity: context.isDarkMode ? 0.025 : 0.045,
              spacing: 66,
            ),
          ),
          ContentWidth(
            child: Padding(
              padding: EdgeInsets.only(
                top: context.responsive(mobile: 52.0, desktop: 72.0),
                bottom: 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (context.isDesktop)
                    _DesktopFooter(
                      foreground: foreground,
                      muted: muted,
                      gold: palette.gold,
                    )
                  else
                    _CompactFooter(
                      foreground: foreground,
                      muted: muted,
                    ),
                  const SizedBox(height: 48),
                  Divider(color: foreground.withValues(alpha: 0.12)),
                  const SizedBox(height: 22),
                  _FooterBottom(foreground: foreground, muted: muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopFooter extends StatelessWidget {
  const _DesktopFooter({
    required this.foreground,
    required this.muted,
    required this.gold,
  });

  final Color foreground;
  final Color muted;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: _BrandColumn(
            foreground: foreground,
            muted: muted,
            gold: gold,
          ),
        ),
        const SizedBox(width: 56),
        Expanded(
          flex: 5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _FooterColumn(
                  title: 'Jelajahi',
                  foreground: foreground,
                  muted: muted,
                  links: const <_FooterLinkData>[
                    _FooterLinkData('Beranda', '/'),
                    _FooterLinkData('Jadwal Shalat', '/jadwal-shalat'),
                    _FooterLinkData("Al-Qur'an", '/quran'),
                    _FooterLinkData('Doa Harian', '/doa'),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _FooterColumn(
                  title: 'Ibadah',
                  foreground: foreground,
                  muted: muted,
                  links: const <_FooterLinkData>[
                    _FooterLinkData('Zikir', '/zikir'),
                    _FooterLinkData('Arah Kiblat', '/kiblat'),
                    _FooterLinkData('Pengaturan', '/pengaturan'),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _FooterTitle('Sumber Data', foreground: foreground),
                    const SizedBox(height: 18),
                    Text(
                      'Teks Al-Qur\u2019an dan terjemahan Indonesia dimuat dari Al Quran Cloud dan ditampilkan dengan atribusi.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: muted, height: 1.65),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Jadwal shalat dihitung secara astronomis di perangkatmu. Verifikasi dengan jadwal resmi setempat.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: muted, height: 1.65),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactFooter extends StatelessWidget {
  const _CompactFooter({required this.foreground, required this.muted});

  final Color foreground;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _BrandColumn(
          foreground: foreground,
          muted: muted,
          gold: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(height: 36),
        Wrap(
          spacing: 36,
          runSpacing: 30,
          children: <Widget>[
            SizedBox(
              width: 140,
              child: _FooterColumn(
                title: 'Jelajahi',
                foreground: foreground,
                muted: muted,
                links: const <_FooterLinkData>[
                  _FooterLinkData('Beranda', '/'),
                  _FooterLinkData('Jadwal Shalat', '/jadwal-shalat'),
                  _FooterLinkData("Al-Qur'an", '/quran'),
                  _FooterLinkData('Doa Harian', '/doa'),
                ],
              ),
            ),
            SizedBox(
              width: 140,
              child: _FooterColumn(
                title: 'Ibadah',
                foreground: foreground,
                muted: muted,
                links: const <_FooterLinkData>[
                  _FooterLinkData('Zikir', '/zikir'),
                  _FooterLinkData('Kiblat', '/kiblat'),
                  _FooterLinkData('Pengaturan', '/pengaturan'),
                ],
              ),
            ),
            SizedBox(
              width: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _FooterTitle('Catatan', foreground: foreground),
                  const SizedBox(height: 16),
                  Text(
                    'Tanpa akun. Preferensi dan bookmark tersimpan di perangkatmu. Jadwal shalat adalah perkiraan astronomis.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: muted, height: 1.65),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandColumn extends StatelessWidget {
  const _BrandColumn({
    required this.foreground,
    required this.muted,
    required this.gold,
  });

  final Color foreground;
  final Color muted;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            BrandMark(
              size: 44,
              background: Colors.white.withValues(alpha: 0.10),
              showShadow: false,
            ),
            const SizedBox(width: 13),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.8,
                    color: foreground,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'TEMAN IBADAH HARIAN',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: muted,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 330),
          child: Text(
            'Ruang tenang untuk jadwal shalat, Al-Qur\u2019an, doa, zikir, dan arah kiblat. Dirancang agar ibadah harian terasa lebih dekat.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: muted,
                  height: 1.7,
                ),
          ),
        ),
        const SizedBox(height: 22),
        GoldRule(width: 54, color: gold),
      ],
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({
    required this.title,
    required this.foreground,
    required this.muted,
    required this.links,
  });

  final String title;
  final Color foreground;
  final Color muted;
  final List<_FooterLinkData> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _FooterTitle(title, foreground: foreground),
        const SizedBox(height: 18),
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: _FooterLink(
              data: link,
              foreground: foreground,
              muted: muted,
            ),
          ),
      ],
    );
  }
}

class _FooterTitle extends StatelessWidget {
  const _FooterTitle(this.label, {required this.foreground});
  final String label;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 1.8,
        fontWeight: FontWeight.w700,
        color: foreground,
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  const _FooterLink({
    required this.data,
    required this.foreground,
    required this.muted,
  });

  final _FooterLinkData data;
  final Color foreground;
  final Color muted;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: () => context.go(widget.data.route),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            widget.data.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _hovered ? widget.foreground : widget.muted,
                  height: 1.4,
                  decoration: _hovered ? TextDecoration.underline : null,
                  decorationColor: widget.foreground.withValues(alpha: 0.4),
                ),
          ),
        ),
      ),
    );
  }
}

class _FooterBottom extends StatelessWidget {
  const _FooterBottom({required this.foreground, required this.muted});

  final Color foreground;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final left = Text(
      '\u00a9 $year Bitaqwa. Dibuat dengan niat baik.',
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: muted, height: 1.5),
    );
    final right = Text(
      'Flutter Web \u00b7 Material 3',
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: muted, height: 1.5),
    );

    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[left, const SizedBox(height: 8), right],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[left, right],
    );
  }
}

class _FooterLinkData {
  const _FooterLinkData(this.label, this.route);
  final String label;
  final String route;
}
