import 'package:flutter/material.dart';

import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/brand.dart';
import '../../domain/zakat_models.dart';
import '../zakat_labels.dart';

class ZakatResultSection extends StatelessWidget {
  const ZakatResultSection({super.key, required this.result});

  final ZakatResult result;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Eyebrow('Hasil perhitungan'),
        const SizedBox(height: 14),
        Text(
          'Perkiraan zakat maal.',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: palette.text),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            'Hasil ini mengikuti input dan asumsi yang Anda pilih. Periksa rincian '
            'dan dalil di bawah sebelum menunaikan zakat.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: palette.muted),
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final hero = _ResultHero(result: result);
            final breakdown = _ResultBreakdown(result: result);
            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[hero, const SizedBox(height: 16), breakdown],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 5, child: hero),
                const SizedBox(width: 18),
                Expanded(flex: 4, child: breakdown),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        _AssumptionsPanel(result: result),
      ],
    );
  }
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({required this.result});

  final ZakatResult result;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDarkMode;
    final status = _StatusCopy.of(result);
    final accent = result.isDue ? palette.primary : palette.gold;
    final background = result.isDue
        ? palette.primarySoft.withValues(alpha: isDark ? 0.38 : 0.62)
        : palette.surfaceAlt.withValues(alpha: isDark ? 0.55 : 0.55);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.34 : 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(status.icon, size: 21, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      status.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: palette.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.muted,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            result.isDue ? 'Estimasi zakat' : 'Zakat yang dihitung',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: palette.muted,
            ),
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatRupiah(result.zakatAmount),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 38,
                height: 1.04,
                letterSpacing: -1.4,
                fontWeight: FontWeight.w500,
                color: result.isDue ? palette.primary : palette.text,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            _amountExplanation(result),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: palette.muted, height: 1.5),
          ),
          if (result.status == ZakatStatus.belowNisab) ...<Widget>[
            const SizedBox(height: 14),
            _InlineFact(
              label: 'Selisih menuju nisab',
              value: formatRupiah(result.nisabShortfall),
            ),
          ],
          if (result.status == ZakatStatus.haulNotFulfilled ||
              result.status == ZakatStatus.haulUnknown) ...<Widget>[
            const SizedBox(height: 14),
            _InlineFact(
              label: 'Jika haul terpenuhi',
              value: formatRupiah(result.estimatedIfDue),
              note: 'Bukan kewajiban final sebelum haul dipastikan.',
            ),
          ],
          const SizedBox(height: 18),
          const GoldRule(width: 44),
        ],
      ),
    );
  }

  String _amountExplanation(ZakatResult result) {
    return switch (result.status) {
      ZakatStatus.due =>
        '2,5% × ${formatRupiah(result.eligibleWealth)}. Dibulatkan ke rupiah terdekat.',
      ZakatStatus.belowNisab =>
        'Harta yang dihitung belum mencapai ambang nisab.',
      ZakatStatus.haulNotFulfilled =>
        'Harta mencapai nisab, tetapi haul belum genap satu tahun Hijriah.',
      ZakatStatus.haulUnknown =>
        'Harta mencapai nisab, tetapi status haul belum dapat dipastikan.',
    };
  }
}

class _StatusCopy {
  const _StatusCopy({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  static _StatusCopy of(ZakatResult result) {
    return switch (result.status) {
      ZakatStatus.due => const _StatusCopy(
        title: 'Mencapai nisab dan haul',
        description:
            'Harta yang dihitung telah mencapai nisab dan status haul yang Anda '
            'pilih adalah sudah terpenuhi.',
        icon: Icons.check_circle_outline_rounded,
      ),
      ZakatStatus.belowNisab => const _StatusCopy(
        title: 'Belum mencapai nisab',
        description:
            'Jumlah harta yang dihitung masih di bawah nisab, sehingga zakat maal '
            'belum dihitung sebagai wajib.',
        icon: Icons.savings_outlined,
      ),
      ZakatStatus.haulNotFulfilled => const _StatusCopy(
        title: 'Haul belum terpenuhi',
        description:
            'Harta sudah mencapai nisab, tetapi belum dimiliki selama satu tahun '
            'Hijriah penuh. Zakat belum dihitung sebagai wajib.',
        icon: Icons.schedule_rounded,
      ),
      ZakatStatus.haulUnknown => const _StatusCopy(
        title: 'Status haul belum pasti',
        description:
            'Harta sudah mencapai nisab, tetapi haul belum dapat dipastikan. Jangan '
            'anggap kewajiban ini pasti sebelum memeriksa tanggal kepemilikan harta.',
        icon: Icons.help_outline_rounded,
      ),
    };
  }
}

class _InlineFact extends StatelessWidget {
  const _InlineFact({required this.label, required this.value, this.note});

  final String label;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surface.withValues(
          alpha: context.isDarkMode ? 0.3 : 0.55,
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11.5, color: palette.muted),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: palette.text,
                ),
              ),
            ],
          ),
          if (note != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              note!,
              style: TextStyle(
                fontSize: 11,
                height: 1.45,
                color: palette.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultBreakdown extends StatelessWidget {
  const _ResultBreakdown({required this.result});

  final ZakatResult result;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final input = result.input;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Rincian perhitungan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                'IDR',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: palette.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _BreakdownGroup(
            title: 'Kas & tabungan',
            total: result.cashTotal,
            lines: <_BreakdownLine>[
              _BreakdownLine('Kas', formatRupiah(input.cash)),
              _BreakdownLine('Tabungan bank', formatRupiah(input.bankSavings)),
              _BreakdownLine('Tabungan lain', formatRupiah(input.otherSavings)),
            ],
          ),
          _breakdownDivider(context),
          _BreakdownGroup(
            title: 'Emas',
            total: result.goldTotal,
            note: result.goldIncluded ? null : _goldExclusionNote(result),
            lines: result.goldIncluded
                ? input.goldValueMode == GoldValueMode.weight
                      ? <_BreakdownLine>[
                          _BreakdownLine(
                            'Berat emas',
                            formatGoldGrams(input.goldWeightMilligrams),
                          ),
                          _BreakdownLine(
                            'Harga per gram',
                            formatRupiah(input.goldPricePerGram),
                          ),
                        ]
                      : <_BreakdownLine>[
                          _BreakdownLine(
                            'Nilai emas',
                            formatRupiah(input.goldMonetaryValue),
                          ),
                        ]
                : const <_BreakdownLine>[],
          ),
          _breakdownDivider(context),
          _BreakdownGroup(
            title: 'Aset perdagangan',
            total: result.tradeTotal,
            lines: <_BreakdownLine>[
              _BreakdownLine(
                'Persediaan dagang',
                formatRupiah(input.tradeInventory),
              ),
              _BreakdownLine('Kas dagang', formatRupiah(input.tradeCash)),
              _BreakdownLine(
                'Piutang tertagih',
                formatRupiah(input.tradeReceivables),
              ),
            ],
          ),
          _breakdownDivider(context),
          _SummaryRow(
            label: 'Total harta dihitung',
            value: formatRupiah(result.eligibleWealth),
            strong: true,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Nisab (85 g emas)',
            value: formatRupiah(result.nisab),
          ),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Kadar zakat', value: '2,5%'),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Status haul', value: haulLabel(result.haul)),
          _breakdownDivider(context),
          _SummaryRow(
            label: 'Zakat maal',
            value: formatRupiah(result.zakatAmount),
            strong: true,
            accent: result.isDue ? palette.primary : null,
          ),
          const SizedBox(height: 12),
          Text(
            'Angka zakat dibulatkan ke rupiah terdekat.',
            style: TextStyle(fontSize: 11, height: 1.5, color: palette.muted),
          ),
        ],
      ),
    );
  }

  String _goldExclusionNote(ZakatResult result) {
    return switch (result.goldPurpose) {
      GoldPurpose.personalJewelry =>
        'Perhiasan pribadi tidak disertakan pada perhitungan ini.',
      GoldPurpose.other =>
        'Emas dengan status belum jelas tidak dimasukkan ke total.',
      GoldPurpose.storedInvestment => 'Nilai emas tidak dimasukkan ke total.',
    };
  }

  Widget _breakdownDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Divider(height: 1, color: context.palette.border),
    );
  }
}

class _BreakdownGroup extends StatelessWidget {
  const _BreakdownGroup({
    required this.title,
    required this.total,
    required this.lines,
    this.note,
  });

  final String title;
  final int total;
  final List<_BreakdownLine> lines;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: palette.text,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              formatRupiah(total),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: palette.text,
              ),
            ),
          ],
        ),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    line.label,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.4,
                      color: palette.muted,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  line.value,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: palette.muted,
                  ),
                ),
              ],
            ),
          ),
        if (note != null) ...<Widget>[
          const SizedBox(height: 7),
          Text(
            note!,
            style: TextStyle(fontSize: 11, height: 1.45, color: palette.gold),
          ),
        ],
      ],
    );
  }
}

class _BreakdownLine {
  const _BreakdownLine(this.label, this.value);

  final String label;
  final String value;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
    this.accent,
  });

  final String label;
  final String value;
  final bool strong;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: strong ? 12 : 11.5,
              fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
              height: 1.4,
              color: strong ? palette.text : palette.muted,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: strong ? 13 : 12,
            fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
            height: 1.4,
            color: accent ?? palette.text,
          ),
        ),
      ],
    );
  }
}

class _AssumptionsPanel extends StatelessWidget {
  const _AssumptionsPanel({required this.result});

  final ZakatResult result;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final assumptions = <String>[
      'Nisab dihitung dari 85 gram emas × harga per gram yang Anda masukkan.',
      'Kadar zakat 2,5% dari harta yang telah mencapai nisab dan haul.',
      'Haul menggunakan satu tahun Hijriah. Status belum atau belum yakin tidak dihitung sebagai kewajiban pasti.',
      'Emas tersimpan atau investasi dihitung. Perhiasan pribadi hanya dihitung jika Anda secara sadar menyertakannya.',
      'Utang tidak dikurangkan otomatis. Piutang dagang hanya dimasukkan bila diperkirakan dapat ditagih.',
      'Penghasilan yang diterima dan dibelanjakan selama tahun berjalan tidak otomatis menjadi harta zakat; masukkan hanya harta yang benar-benar tersimpan.',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: palette.primarySoft.withValues(
                    alpha: context.isDarkMode ? 0.55 : 1,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.rule_outlined,
                  size: 18,
                  color: palette.primary,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Asumsi yang digunakan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final assumption in assumptions)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: palette.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      assumption,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.55,
                        color: palette.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!result.goldIncluded &&
              result.goldPurpose == GoldPurpose.personalJewelry) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              'Catatan: perhiasan pribadi tidak dihitung pada hasil ini. Jika Anda '
              'mengikuti pendapat yang mewajibkan zakat perhiasan, aktifkan pilihan '
              'penyertaan di formulir lalu hitung ulang.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.55,
                color: palette.gold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
