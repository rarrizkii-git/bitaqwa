import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/lecture.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/bitaqwa_palette.dart';

class KajianFilterBar extends ConsumerWidget {
  const KajianFilterBar({
    super.key,
    required this.controller,
    required this.query,
    required this.selectedCategory,
    required this.selectedUstadzId,
    required this.onChanged,
    required this.onClearSearch,
    required this.onSelectCategory,
    required this.onSelectUstadz,
    required this.onReset,
  });

  final TextEditingController controller;
  final String query;
  final LectureCategory? selectedCategory;
  final String? selectedUstadzId;
  final ValueChanged<String> onChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<LectureCategory?> onSelectCategory;
  final ValueChanged<String?> onSelectUstadz;
  final VoidCallback onReset;

  bool get _hasFilters =>
      query.trim().isNotEmpty ||
      selectedCategory != null ||
      selectedUstadzId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final catalog = ref.watch(kajianCatalogProvider);
    final selectedUstadz = catalog.ustadzById(selectedUstadzId);

    final search = TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari judul kajian, ustadz, atau tema',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                onPressed: onClearSearch,
                tooltip: 'Hapus pencarian',
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
      ),
    );

    final categoryMenu = _FilterMenu(
      icon: Icons.grid_view_rounded,
      value: selectedCategory?.label ?? 'Semua tema',
      isActive: selectedCategory != null,
      tooltip: 'Saring berdasarkan tema',
      onSelected: (value) => onSelectCategory(LectureCategory.fromSlug(value)),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: '',
          child: _MenuItemRow(
            label: 'Semua tema',
            count: catalog.allLectures.length,
          ),
        ),
        const PopupMenuDivider(),
        for (final category in LectureCategory.values)
          PopupMenuItem<String>(
            value: category.slug,
            child: _MenuItemRow(
              label: category.label,
              count: catalog.countForCategory(category),
            ),
          ),
      ],
    );

    final ustadzMenu = _FilterMenu(
      icon: Icons.person_outline_rounded,
      value: selectedUstadz?.name ?? 'Semua ustadz',
      isActive: selectedUstadzId != null,
      tooltip: 'Saring berdasarkan ustadz',
      onSelected: (value) => onSelectUstadz(value.isEmpty ? null : value),
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: '',
          child: _MenuItemRow(
            label: 'Semua ustadz',
            count: null,
          ),
        ),
        const PopupMenuDivider(),
        for (final ustadz in catalog.allUstadz)
          PopupMenuItem<String>(
            value: ustadz.id,
            child: _MenuItemRow(
              label: ustadz.displayName,
              count: catalog.countForUstadz(ustadz.id),
            ),
          ),
      ],
    );

    final reset = _hasFilters
        ? TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
            label: const Text('Reset'),
          )
        : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          if (width >= 900) {
            return Row(
              children: <Widget>[
                Expanded(child: search),
                const SizedBox(width: 12),
                SizedBox(width: 208, child: categoryMenu),
                const SizedBox(width: 12),
                SizedBox(width: 226, child: ustadzMenu),
                if (reset != null) ...<Widget>[
                  const SizedBox(width: 4),
                  reset,
                ],
              ],
            );
          }

          if (width >= 620) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                search,
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(child: categoryMenu),
                    const SizedBox(width: 12),
                    Expanded(child: ustadzMenu),
                    if (reset != null) ...<Widget>[
                      const SizedBox(width: 4),
                      reset,
                    ],
                  ],
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              search,
              const SizedBox(height: 10),
              categoryMenu,
              const SizedBox(height: 10),
              ustadzMenu,
              if (reset != null) ...<Widget>[
                const SizedBox(height: 6),
                Align(alignment: Alignment.centerLeft, child: reset),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FilterMenu extends StatelessWidget {
  const _FilterMenu({
    required this.icon,
    required this.value,
    required this.isActive,
    required this.tooltip,
    required this.onSelected,
    required this.items,
  });

  final IconData icon;
  final String value;
  final bool isActive;
  final String tooltip;
  final ValueChanged<String> onSelected;
  final List<PopupMenuEntry<String>> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return PopupMenuButton<String>(
      tooltip: tooltip,
      onSelected: onSelected,
      itemBuilder: (context) => items,
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(minWidth: 250, maxWidth: 300),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isActive
              ? palette.primarySoft.withValues(
                  alpha: context.isDarkMode ? 0.45 : 0.65,
                )
              : palette.surfaceAlt.withValues(
                  alpha: context.isDarkMode ? 0.45 : 0.55,
                ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? palette.primary.withValues(alpha: 0.32)
                : palette.border,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: 17,
              color: isActive ? palette.primary : palette.muted,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isActive ? palette.primary : palette.text,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: isActive ? palette.primary : palette.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemRow extends StatelessWidget {
  const _MenuItemRow({required this.label, required this.count});

  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: palette.text),
          ),
        ),
        if (count != null) ...<Widget>[
          const SizedBox(width: 10),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: palette.muted,
            ),
          ),
        ],
      ],
    );
  }
}
