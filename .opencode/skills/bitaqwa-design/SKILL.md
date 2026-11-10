---
name: Bitaqwa Design
description: Visual, layout, and interaction guidance for Bitaqwa Flutter UI work, including the emerald/gold brand system, typography, shared widgets, responsive behavior, and Arabic content
---

# Bitaqwa Design

Read and follow `AGENTS.md` first. Also load the `frontend-design` skill. This skill only adds Bitaqwa-specific context; do not duplicate or replace those guidelines.

## Design system

- Theme tokens: `lib/core/theme/app_colors.dart`, `app_typography.dart`, `app_theme.dart`.
- Read colors through `context.palette` (`BitaqwaPalette` in `lib/core/theme/bitaqwa_palette.dart`). Never hard-code brand colors or branch on brightness manually.
- Typography: `AppTypography`/`Theme.of(context).textTheme`. Fraunces for editorial headlines, Plus Jakarta Sans for body copy, Amiri for Arabic. Keep Arabic `textDirection: TextDirection.rtl` where appropriate.
- Layout: `lib/shared/layout/page_scaffold.dart` (`PageScaffold`, `SectionHeading`, `PageHeader`), `navbar.dart`, `footer.dart`.
- Shared widgets: `app_button.dart`, `brand.dart`, `city_picker.dart`, `hover_card.dart`, `islamic_art.dart`, `prayer_visuals.dart`, `reveal.dart`.
- Responsive helpers: `lib/core/utils/responsive.dart` and `context.responsive(mobile:, tablet:, desktop:)`.
- Feature screens live in `lib/features/<feature>/presentation`, with page-specific widgets in a `widgets/` subfolder.

## Design direction

- Modern, calm, minimal Islamic aesthetic. No generic card grids, default gradients, or excessive rounding.
- Strong hierarchy, generous but purposeful spacing, restrained ornament, and one clear focal point per section.
- Preserve the emerald, warm-neutral, and gold identity in both light and dark themes.
- Treat Islamic content with care: correct Arabic, readable sizes, and no decorative treatment that harms legibility.

## Workflow

1. Read `AGENTS.md` and inspect the existing screen, theme tokens, and reusable widgets.
2. State the visual direction and the hierarchy before proposing layout details.
3. Reuse existing components; justify any new widget.
4. Plan mobile, tablet, and desktop behavior plus empty, loading, and error states.
5. Check contrast, tap targets, focus states, reduced motion, and Arabic alignment.
6. After implementation, compare the result against the plan and the design system.

## Guardrails

- No new dependencies, assets, fonts, or placeholder content unless explicitly requested.
- Do not redesign unrelated screens.
- Do not claim visual behavior was verified unless it was actually rendered or tested.
