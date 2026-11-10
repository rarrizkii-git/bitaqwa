import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/bitaqwa_palette.dart';
import '../../core/utils/responsive.dart';
import '../widgets/app_button.dart';
import '../widgets/brand.dart';

class _NavItem {
  const _NavItem(this.label, this.route, {this.aliases = const <String>[]});
  final String label;
  final String route;
  final List<String> aliases;
}

const _primaryNav = <_NavItem>[
  _NavItem('Beranda', '/'),
  _NavItem('Jadwal Shalat', '/jadwal-shalat'),
  _NavItem("Al-Qur'an", '/quran'),
  _NavItem('Doa & Zikir', '/doa', aliases: <String>['/zikir']),
  _NavItem('Kajian', '/kajian'),
  _NavItem('Zakat', '/zakat'),
];

class SiteNavbar extends ConsumerStatefulWidget {
  const SiteNavbar({super.key, required this.location});

  /// Current path from the router. Passed in by the shell because the navbar
  /// lives outside the individual route builders.
  final String location;

  @override
  ConsumerState<SiteNavbar> createState() => _SiteNavbarState();
}

class _SiteNavbarState extends ConsumerState<SiteNavbar> {
  bool _menuVisible = false;

  Future<void> _openMenu(String location) async {
    setState(() => _menuVisible = true);
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup menu',
      barrierColor: Colors.black.withValues(alpha: 0.46),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (dialogContext, _, _) {
        return _MobileMenuDrawer(location: location);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
    if (mounted) setState(() => _menuVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scrollState = ref.watch(navScrollProvider);
    final location = widget.location;
    final desktop = context.isDesktop;
    final height = desktop
        ? AppConstants.navHeight
        : AppConstants.navHeightMobile;
    final showQuickActions = context.screenWidth >= 1180;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        height: height,
        decoration: BoxDecoration(
          color: scrollState.scrolled ? palette.navSurface : palette.background,
          border: Border(
            bottom: BorderSide(
              color: scrollState.scrolled ? palette.border : Colors.transparent,
            ),
          ),
          boxShadow: scrollState.scrolled
              ? <BoxShadow>[
                  BoxShadow(
                    color:
                        (context.isDarkMode
                                ? Colors.black
                                : palette.primaryDeep)
                            .withValues(
                              alpha: context.isDarkMode ? 0.24 : 0.05,
                            ),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ContentWidth(
                child: desktop
                    ? Row(
                        children: <Widget>[
                          BrandLockup(onTap: () => context.go('/')),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: <Widget>[
                                for (final item in _primaryNav)
                                  _NavLink(
                                    item: item,
                                    location: location,
                                    onTap: () => context.go(item.route),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (showQuickActions) ...<Widget>[
                            _CircleAction(
                              icon: Icons.explore_outlined,
                              tooltip: 'Arah Kiblat',
                              onTap: () => context.go('/kiblat'),
                            ),
                            const SizedBox(width: 4),
                            _CircleAction(
                              icon: Icons.settings_outlined,
                              tooltip: 'Pengaturan',
                              onTap: () => context.go('/pengaturan'),
                            ),
                            const SizedBox(width: 4),
                          ],
                          const ThemeToggleButton(),
                          const SizedBox(width: 14),
                          AppButton(
                            label: 'Mulai Sekarang',
                            size: AppButtonSize.compact,
                            trailingIcon: Icons.arrow_forward_rounded,
                            onPressed: () => context.go('/jadwal-shalat'),
                          ),
                        ],
                      )
                    : Row(
                        children: <Widget>[
                          Expanded(
                            child: BrandLockup(
                              markSize: 38,
                              showTagline: false,
                              onTap: () => context.go('/'),
                            ),
                          ),
                          const ThemeToggleButton(compact: true),
                          const SizedBox(width: 8),
                          _HamburgerButton(
                            open: _menuVisible,
                            onTap: () => _openMenu(location),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(
              height: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: scrollState.progress,
                  child: Container(color: palette.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.item,
    required this.location,
    required this.onTap,
  });

  final _NavItem item;
  final String location;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  bool get _active {
    if (widget.item.route == '/') return widget.location == '/';
    return widget.location.startsWith(widget.item.route) ||
        widget.item.aliases.any(widget.location.startsWith);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = _active || _hovered ? palette.primary : palette.text;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: _active ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: _active ? 16 : (_hovered ? 10 : 0),
                height: 2,
                decoration: BoxDecoration(
                  color: _active ? palette.primary : palette.gold,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatefulWidget {
  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_CircleAction> createState() => _CircleActionState();
}

class _CircleActionState extends State<_CircleAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkResponse(
          onTap: widget.onTap,
          radius: 22,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _hovered
                  ? palette.primary.withValues(alpha: 0.09)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              size: 19,
              color: _hovered ? palette.primary : palette.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _HamburgerButton extends StatelessWidget {
  const _HamburgerButton({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Tooltip(
      message: open ? 'Tutup menu' : 'Buka menu',
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: open ? palette.primarySoft : palette.surface,
            shape: BoxShape.circle,
            border: Border.all(color: palette.border),
          ),
          child: Center(
            child: SizedBox(
              width: 18,
              height: 14,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  _Bar(
                    top: 0,
                    rotation: open ? math.pi / 4 : 0,
                    translateY: open ? 6 : 0,
                    color: open ? palette.primary : palette.text,
                  ),
                  _Bar(
                    top: 6,
                    opacity: open ? 0 : 1,
                    color: open ? palette.primary : palette.text,
                  ),
                  _Bar(
                    top: 12,
                    rotation: open ? -math.pi / 4 : 0,
                    translateY: open ? -6 : 0,
                    color: open ? palette.primary : palette.text,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.top,
    required this.color,
    this.rotation = 0,
    this.translateY = 0,
    this.opacity = 1,
  });

  final double top;
  final Color color;
  final double rotation;
  final double translateY;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      top: top,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: opacity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          height: 1.8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
          transform: Matrix4.translationValues(0, translateY, 0)
            ..rotateZ(rotation),
          transformAlignment: Alignment.center,
        ),
      ),
    );
  }
}

class _MobileMenuDrawer extends ConsumerWidget {
  const _MobileMenuDrawer({required this.location});

  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final width = math.min(MediaQuery.sizeOf(context).width * 0.88, 380.0);

    final links = <_MenuLink>[
      const _MenuLink('Beranda', '/', Icons.home_outlined),
      const _MenuLink(
        'Jadwal Shalat',
        '/jadwal-shalat',
        Icons.access_time_rounded,
      ),
      const _MenuLink("Al-Qur'an", '/quran', Icons.menu_book_outlined),
      const _MenuLink('Doa Harian', '/doa', Icons.volunteer_activism_outlined),
      const _MenuLink('Zikir', '/zikir', Icons.spa_outlined),
      const _MenuLink('Kajian Online', '/kajian', Icons.play_circle_outline_rounded),
      const _MenuLink('Zakat', '/zakat', Icons.calculate_outlined),
      const _MenuLink('Arah Kiblat', '/kiblat', Icons.explore_outlined),
      const _MenuLink('Pengaturan', '/pengaturan', Icons.settings_outlined),
    ];

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: palette.surface,
        child: Container(
          width: width,
          height: double.infinity,
          decoration: BoxDecoration(
            color: palette.surface,
            border: Border(left: BorderSide(color: palette.border)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 40,
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
                  child: Row(
                    children: <Widget>[
                      BrandLockup(
                        markSize: 36,
                        showTagline: false,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go('/');
                        },
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Tutup menu',
                      ),
                    ],
                  ),
                ),
                Divider(color: palette.border),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                    children: <Widget>[
                      for (int i = 0; i < links.length; i++)
                        _DrawerLink(
                          link: links[i],
                          active: _isActive(links[i].route),
                          index: i,
                          onTap: () {
                            Navigator.of(context).pop();
                            context.go(links[i].route);
                          },
                        ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: palette.surfaceAlt.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: palette.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Tampilan',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Ganti mode terang atau gelap',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: palette.muted),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const ThemeToggleButton(compact: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      AppButton(
                        label: 'Mulai Sekarang',
                        icon: Icons.arrow_forward_rounded,
                        expand: true,
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go('/jadwal-shalat');
                        },
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Tanpa akun. Preferensi dan bookmark tersimpan di perangkatmu.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.muted,
                          height: 1.5,
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
    );
  }

  bool _isActive(String route) {
    if (route == '/') return location == '/';
    return location.startsWith(route);
  }
}

class _MenuLink {
  const _MenuLink(this.label, this.route, this.icon);
  final String label;
  final String route;
  final IconData icon;
}

class _DrawerLink extends StatelessWidget {
  const _DrawerLink({
    required this.link,
    required this.active,
    required this.index,
    required this.onTap,
  });

  final _MenuLink link;
  final bool active;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: active
                ? palette.primarySoft.withValues(
                    alpha: context.isDarkMode ? 0.6 : 1,
                  )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      link.icon,
                      size: 19,
                      color: active ? palette.primary : palette.muted,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        link.label,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: active ? palette.primary : palette.text,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: palette.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: 320.ms,
          delay: Duration(milliseconds: 45 * index),
          curve: Curves.easeOut,
        )
        .slideX(
          begin: 0.08,
          end: 0,
          duration: 320.ms,
          delay: Duration(milliseconds: 45 * index),
          curve: Curves.easeOutCubic,
        );
  }
}
