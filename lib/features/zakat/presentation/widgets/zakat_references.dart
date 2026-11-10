import 'package:flutter/material.dart';

import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../core/utils/external_url.dart';
import '../../../../shared/widgets/brand.dart';

/// Verified sources behind the calculator's fixed assumptions.
///
/// Texts are explained in Indonesian rather than quoted verbatim so the page
/// never presents an unverified translation or a hadith grade it cannot
/// attribute.
class ZakatReferences extends StatelessWidget {
  const ZakatReferences({
    super.key,
    required this.expanded,
    required this.onToggle,
  });

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ReferencesHeader(expanded: expanded, onToggle: onToggle),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: expanded
                ? _ReferencesBody(onToggle: onToggle)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ReferencesHeader extends StatelessWidget {
  const _ReferencesHeader({required this.expanded, required this.onToggle});

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      expanded: expanded,
      label:
          'Dalil dan referensi. Sumber yang digunakan. Enam rujukan untuk nisab, '
          'haul, kadar zakat, dan harta yang dihitung. ${expanded ? 'Tutup' : 'Buka'}.',
      onTap: onToggle,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: palette.primarySoft.withValues(
                      alpha: context.isDarkMode ? 0.55 : 1,
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.menu_book_outlined,
                    size: 20,
                    color: palette.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Eyebrow('Dalil & referensi'),
                      const SizedBox(height: 6),
                      Text(
                        'Sumber yang digunakan.',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: palette.text),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Enam rujukan untuk nisab, haul, kadar zakat, dan harta '
                        'yang dihitung. Buka sumber untuk membaca teks lengkapnya.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.muted,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: palette.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expanded ? 'Tutup' : 'Buka',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: palette.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReferencesBody extends StatelessWidget {
  const _ReferencesBody({required this.onToggle});

  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Divider(height: 1, color: palette.border),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
          child: Text(
            'Penjelasan di bawah adalah ringkasan makna, bukan kutipan terjemahan '
            'resmi. Setiap tautan membuka sumber aslinya di tab baru.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.55,
              color: palette.muted,
            ),
          ),
        ),
        for (var index = 0; index < _references.length; index++) ...<Widget>[
          _ReferenceRow(reference: _references[index]),
          if (index != _references.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(height: 1, color: palette.border),
            ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Row(
            children: <Widget>[
              Icon(Icons.verified_outlined, size: 16, color: palette.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tautan dan derajat hadis mengikuti halaman sumber yang '
                  'dicantumkan.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.5,
                    color: palette.muted,
                  ),
                ),
              ),
              TextButton(onPressed: onToggle, child: const Text('Tutup dalil')),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  const _ReferenceRow({required this.reference});

  final _ZakatReference reference;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = switch (reference.kind) {
      _ReferenceKind.quran => palette.primary,
      _ReferenceKind.hadith => palette.gold,
      _ReferenceKind.institution => palette.muted,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              _KindBadge(label: reference.kindLabel, color: tone),
              Text(
                reference.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: palette.text,
                ),
              ),
              Text(
                reference.locator,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: palette.muted,
                ),
              ),
              if (reference.grade != null) _GradeBadge(label: reference.grade!),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reference.explanation,
            style: TextStyle(fontSize: 12.5, height: 1.6, color: palette.muted),
          ),
          const SizedBox(height: 10),
          _SourceLink(label: reference.linkLabel, url: reference.url),
        ],
      ),
    );
  }
}

class _KindBadge extends StatelessWidget {
  const _KindBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDarkMode ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: color.withValues(alpha: context.isDarkMode ? 0.3 : 0.18),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(
          alpha: context.isDarkMode ? 0.55 : 0.8,
        ),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.verified_outlined, size: 12, color: palette.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: palette.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceLink extends StatefulWidget {
  const _SourceLink({required this.label, required this.url});

  final String label;
  final String url;

  @override
  State<_SourceLink> createState() => _SourceLinkState();
}

class _SourceLinkState extends State<_SourceLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = _hovered ? palette.primary : palette.muted;
    return Semantics(
      link: true,
      label: '${widget.label}. Membuka tab baru.',
      onTap: () => openExternalUrl(widget.url),
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          onTap: () => openExternalUrl(widget.url),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: tone,
                    decoration: _hovered ? TextDecoration.underline : null,
                    decorationColor: palette.primary.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 5),
                Icon(Icons.open_in_new_rounded, size: 13.5, color: tone),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _ReferenceKind { quran, hadith, institution }

class _ZakatReference {
  const _ZakatReference({
    required this.kind,
    required this.title,
    required this.locator,
    required this.explanation,
    required this.linkLabel,
    required this.url,
    this.grade,
  });

  final _ReferenceKind kind;
  final String title;
  final String locator;
  final String explanation;
  final String linkLabel;
  final String url;
  final String? grade;

  String get kindLabel => switch (kind) {
    _ReferenceKind.quran => "Al-Qur'an",
    _ReferenceKind.hadith => 'Hadis',
    _ReferenceKind.institution => 'Lembaga',
  };
}

const _references = <_ZakatReference>[
  _ZakatReference(
    kind: _ReferenceKind.quran,
    title: 'Surah At-Tawbah',
    locator: '9:103',
    explanation:
        'Perintah mengambil sedekah dari harta untuk membersihkan dan menyucikan '
        'pemiliknya. Ayat ini menjadi landasan kewajiban zakat atas harta.',
    linkLabel: 'Buka di Quran.com',
    url: 'https://quran.com/at-tawbah/103',
  ),
  _ZakatReference(
    kind: _ReferenceKind.quran,
    title: 'Surah Al-Baqarah',
    locator: '2:267',
    explanation:
        'Perintah menafkahkan harta yang baik dari hasil usaha. Harta yang '
        'dizakati adalah harta halal dan baik, bukan harta yang buruk.',
    linkLabel: 'Buka di Quran.com',
    url: 'https://quran.com/al-baqarah/267',
  ),
  _ZakatReference(
    kind: _ReferenceKind.hadith,
    title: 'Sunan Ibn Majah',
    locator: '1792',
    grade: 'Hasan (Darussalam)',
    explanation:
        'Tidak ada zakat pada harta sampai berlalu satu haul. Hadis ini menjadi '
        'dasar mengapa status haul ditanyakan secara terpisah.',
    linkLabel: 'Buka di Sunnah.com',
    url: 'https://sunnah.com/ibnmajah:1792',
  ),
  _ZakatReference(
    kind: _ReferenceKind.hadith,
    title: 'Musnad Ahmad',
    locator: '1265',
    grade: 'Sahih (Darussalam)',
    explanation:
        'Zakat harta baru wajib setelah satu tahun berlalu. Bila haul belum '
        'terpenuhi atau belum pasti, hasil tidak ditampilkan sebagai kewajiban.',
    linkLabel: 'Buka di Sunnah.com',
    url: 'https://sunnah.com/ahmad:1265',
  ),
  _ZakatReference(
    kind: _ReferenceKind.institution,
    title: 'BAZNAS',
    locator: 'Kalkulator Zakat',
    explanation:
        'Kalkulator resmi BAZNAS menggunakan nisab 85 gram emas dan kadar 2,5% '
        'untuk zakat emas. Angka inilah yang dipakai sebagai asumsi tetap.',
    linkLabel: 'Buka kalkulator BAZNAS',
    url: 'https://www.baznas.go.id/kalkulatorzakat',
  ),
  _ZakatReference(
    kind: _ReferenceKind.institution,
    title: 'Kementerian Agama RI',
    locator: 'Situs resmi',
    explanation:
        'Situs resmi Kementerian Agama RI. Gunakan kanal ini untuk memeriksa '
        'regulasi dan panduan zakat yang berlaku di Indonesia.',
    linkLabel: 'Buka situs Kemenag',
    url: 'https://kemenag.go.id/',
  ),
];
