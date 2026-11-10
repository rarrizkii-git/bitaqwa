import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../shared/layout/page_scaffold.dart';
import 'widgets/dua_preview_section.dart';
import 'widgets/features_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/prayer_preview_section.dart';
import 'widgets/quran_preview_section.dart';
import 'widgets/reminder_section.dart';
import 'widgets/stats_cta_sections.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _controller = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(navScrollProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showFeatures() {
    final target = _featuresKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOutCubic,
      alignment: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      controller: _controller,
      child: Column(
        children: <Widget>[
          HeroSection(
            scrollController: _controller,
            onExplore: _showFeatures,
          ),
          FeaturesSection(key: _featuresKey),
          const PrayerPreviewSection(),
          const QuranPreviewSection(),
          const DuaPreviewSection(),
          const ReminderSection(),
          const StatsSection(),
          const CtaSection(),
        ],
      ),
    );
  }
}