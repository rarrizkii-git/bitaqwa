import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/ustadz.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../shared/widgets/reveal.dart';
import 'kajian_visuals.dart';

class KajianUstadzCard extends ConsumerStatefulWidget {
  const KajianUstadzCard({super.key, required this.ustadz});

  final Ustadz ustadz;

  @override
  ConsumerState<KajianUstadzCard> createState() => _KajianUstadzCardState();
}

class _KajianUstadzCardState extends ConsumerState<KajianUstadzCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ustadz = widget.ustadz;
    final count = ref.watch(kajianCatalogProvider).countForUstadz(ustadz.id);

    return Semantics(
      button: true,
      label: 'Buka profil ${ustadz.displayName}, $count kajian',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered
                  ? palette.primary.withValues(alpha: 0.34)
                  : palette.border,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/kajian/ustadz/${ustadz.id}'),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: <Widget>[
                    KajianUstadzAvatar(
                      initials: ustadz.monogram,
                      imageUrl: ustadz.imageUrl,
                      size: 56,
                      radius: 16,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            ustadz.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontSize: 14.5, color: palette.text),
                          ),
                          if (ustadz.credentials != null) ...<Widget>[
                            const SizedBox(height: 2),
                            Text(
                              ustadz.credentials!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: palette.goldInk,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 5),
                          Text(
                            ustadz.channelName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: palette.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '$count kajian',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: palette.muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          Icons.arrow_outward_rounded,
                          size: 16,
                          color: _hovered ? palette.primary : palette.muted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class KajianUstadzGrid extends StatelessWidget {
  const KajianUstadzGrid({super.key, required this.ustadzList});

  final List<Ustadz> ustadzList;

  @override
  Widget build(BuildContext context) {
    if (ustadzList.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1040 ? 3 : (width >= 660 ? 2 : 1);
        final gap = width >= 660 ? 16.0 : 12.0;
        final cardWidth = (width - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (int i = 0; i < ustadzList.length; i++)
              SizedBox(
                width: cardWidth,
                // Tall enough for the three-line layout (name, optional
                // credentials, channel) once the webfont has loaded; a shorter
                // box overflows by a few pixels on cards that show a title.
                height: 104,
                child: StaggeredReveal(
                  index: i > 8 ? 8 : i,
                  child: KajianUstadzCard(ustadz: ustadzList[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}
