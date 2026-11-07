import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/cities.dart';
import '../../core/models/city.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/bitaqwa_palette.dart';
import '../../core/utils/responsive.dart';

Future<void> showCityPicker(BuildContext context) async {
  if (context.isMobile) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final palette = context.palette;
        return FractionallySizedBox(
          heightFactor: 0.86,
          child: Container(
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: const CityPickerContent(),
          ),
        );
      },
    );
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (context) {
      final palette = context.palette;
      return Dialog(
        insetPadding: const EdgeInsets.all(32),
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: palette.border),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 480, maxHeight: 640),
          child: CityPickerContent(),
        ),
      );
    },
  );
}

class CityPickerButton extends ConsumerWidget {
  const CityPickerButton({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(selectedCityProvider);
    final palette = context.palette;

    return Semantics(
      button: true,
      label: 'Pilih kota. Saat ini ${city.label}',
      child: InkWell(
        onTap: () => showCityPicker(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 13 : 16,
            vertical: compact ? 10 : 13,
          ),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.location_on_outlined,
                size: compact ? 16 : 18,
                color: palette.primary,
              ),
              const SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    city.name,
                    style: TextStyle(
                      fontSize: compact ? 12.5 : 13.5,
                      fontWeight: FontWeight.w600,
                      color: palette.text,
                    ),
                  ),
                  if (!compact)
                    Text(
                      city.timezoneLabel,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: palette.muted,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: palette.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CityPickerContent extends ConsumerStatefulWidget {
  const CityPickerContent({super.key});

  @override
  ConsumerState<CityPickerContent> createState() => _CityPickerContentState();
}

class _CityPickerContentState extends ConsumerState<CityPickerContent> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selected = ref.watch(selectedCityProvider);
    final results = _filter(_query);
    final isSheet = context.isMobile;

    return Padding(
      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        top: isSheet ? 14 : 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (isSheet)
            Center(
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: palette.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Pilih lokasi',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jadwal shalat dan arah kiblat menyesuaikan kotamu.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: palette.muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Tutup',
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _searchController,
            autofocus: !isSheet,
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari kota atau daerah',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded, size: 18),
                      tooltip: 'Hapus pencarian',
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.travel_explore_rounded,
                          size: 34,
                          color: palette.muted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Kota tidak ditemukan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Coba nama kota atau provinsi lain.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: palette.muted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final city = results[index];
                      return _CityTile(
                        city: city,
                        selected: city == selected,
                        onTap: () {
                          ref.read(selectedCityProvider.notifier).select(city);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<City> _filter(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return Cities.all;
    return Cities.all.where((city) {
      return city.name.toLowerCase().contains(normalized) ||
          city.region.toLowerCase().contains(normalized) ||
          city.timezoneLabel.toLowerCase().contains(normalized);
    }).toList(growable: false);
  }
}

class _CityTile extends StatefulWidget {
  const _CityTile({
    required this.city,
    required this.selected,
    required this.onTap,
  });

  final City city;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CityTile> createState() => _CityTileState();
}

class _CityTileState extends State<_CityTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final highlighted = widget.selected || _hovered;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: highlighted
                ? palette.primarySoft.withValues(
                    alpha: context.isDarkMode ? 0.55 : 1,
                  )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: highlighted
                  ? palette.primary.withValues(alpha: 0.28)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: highlighted
                      ? palette.primary.withValues(alpha: 0.12)
                      : palette.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.place_outlined,
                  size: 17,
                  color: highlighted ? palette.primary : palette.muted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.city.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: palette.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.city.region} \u00b7 ${widget.city.timezoneLabel}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: palette.muted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.selected)
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: palette.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
