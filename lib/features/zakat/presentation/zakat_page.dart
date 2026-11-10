import 'package:flutter/material.dart';

import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/layout/page_scaffold.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/brand.dart';
import '../domain/zakat_calculator.dart';
import '../domain/zakat_models.dart';
import '../domain/zakat_parsing.dart';
import '../domain/zakat_rules.dart';
import 'widgets/zakat_fields.dart';
import 'widgets/zakat_references.dart';
import 'widgets/zakat_result_section.dart';

class ZakatPage extends StatefulWidget {
  const ZakatPage({super.key});

  @override
  State<ZakatPage> createState() => _ZakatPageState();
}

class _ZakatPageState extends State<ZakatPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultKey = GlobalKey();
  final GlobalKey _referencesKey = GlobalKey();

  final TextEditingController _goldPrice = TextEditingController();
  final TextEditingController _cash = TextEditingController();
  final TextEditingController _bankSavings = TextEditingController();
  final TextEditingController _otherSavings = TextEditingController();
  final TextEditingController _goldWeight = TextEditingController();
  final TextEditingController _goldValue = TextEditingController();
  final TextEditingController _tradeInventory = TextEditingController();
  final TextEditingController _tradeCash = TextEditingController();
  final TextEditingController _tradeReceivables = TextEditingController();

  GoldValueMode _goldValueMode = GoldValueMode.weight;
  GoldPurpose _goldPurpose = GoldPurpose.storedInvestment;
  bool _includePersonalJewelry = false;
  HaulStatus? _haul;

  Map<String, String> _errors = <String, String>{};
  String? _formError;
  ZakatResult? _result;
  bool _dirty = false;
  bool _referencesExpanded = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _goldPrice.dispose();
    _cash.dispose();
    _bankSavings.dispose();
    _otherSavings.dispose();
    _goldWeight.dispose();
    _goldValue.dispose();
    _tradeInventory.dispose();
    _tradeCash.dispose();
    _tradeReceivables.dispose();
    super.dispose();
  }

  int? get _goldPriceValue {
    final raw = _goldPrice.text.trim();
    if (raw.isEmpty) return null;
    final value = ZakatParsing.parseRupiah(raw);
    if (value == null || value <= 0 || value > ZakatRules.maxGoldPricePerGram) {
      return null;
    }
    return value;
  }

  int? get _nisabPreview {
    final price = _goldPriceValue;
    if (price == null) return null;
    return ZakatRules.nisabFor(price);
  }

  bool get _goldIncluded {
    return switch (_goldPurpose) {
      GoldPurpose.storedInvestment => true,
      GoldPurpose.personalJewelry => _includePersonalJewelry,
      GoldPurpose.other => false,
    };
  }

  void _onGoldPriceChanged(String _) {
    setState(() {
      _errors = <String, String>{..._errors}..remove('goldPrice');
      _formError = null;
      if (_result != null) _dirty = true;
    });
  }

  void _onFieldChanged(String key) {
    final needsRebuild =
        _errors.containsKey(key) ||
        _formError != null ||
        (_result != null && !_dirty);
    if (!needsRebuild) return;
    setState(() {
      _errors = <String, String>{..._errors}..remove(key);
      _formError = null;
      if (_result != null) _dirty = true;
    });
  }

  void _markDirty() {
    if (_result != null && !_dirty) {
      setState(() => _dirty = true);
    }
  }

  int? _parseAmount(
    String key,
    TextEditingController controller,
    Map<String, String> errors, {
    bool required = false,
    int max = ZakatRules.maxRupiah,
  }) {
    final raw = controller.text.trim();
    if (raw.isEmpty) {
      if (required) errors[key] = 'Kolom ini wajib diisi.';
      return required ? null : 0;
    }

    final value = ZakatParsing.parseRupiah(raw);
    if (value == null) {
      errors[key] = 'Nilai tidak valid.';
      return null;
    }
    if (value > max) {
      errors[key] = 'Nilai melebihi batas perhitungan.';
      return null;
    }
    return value;
  }

  int? _parseGoldWeight(Map<String, String> errors) {
    final raw = _goldWeight.text.trim();
    if (raw.isEmpty) return 0;

    final value = ZakatParsing.parseGoldWeightMilligrams(raw);
    if (value == null) {
      errors['goldWeight'] = 'Berat emas tidak valid.';
      return null;
    }
    if (value > ZakatRules.maxGoldWeightMilligrams) {
      errors['goldWeight'] = 'Berat emas melebihi batas perhitungan.';
      return null;
    }
    return value;
  }

  ZakatInput? _collectInput() {
    final errors = <String, String>{};

    final price = _parseAmount(
      'goldPrice',
      _goldPrice,
      errors,
      required: true,
      max: ZakatRules.maxGoldPricePerGram,
    );
    if (price == 0) {
      errors['goldPrice'] = 'Harga emas harus lebih dari 0.';
    }

    final cash = _parseAmount('cash', _cash, errors) ?? 0;
    final bankSavings = _parseAmount('bankSavings', _bankSavings, errors) ?? 0;
    final otherSavings =
        _parseAmount('otherSavings', _otherSavings, errors) ?? 0;
    final tradeInventory =
        _parseAmount('tradeInventory', _tradeInventory, errors) ?? 0;
    final tradeCash = _parseAmount('tradeCash', _tradeCash, errors) ?? 0;
    final tradeReceivables =
        _parseAmount('tradeReceivables', _tradeReceivables, errors) ?? 0;

    var goldWeightMilligrams = 0;
    var goldMonetaryValue = 0;
    if (_goldIncluded) {
      if (_goldValueMode == GoldValueMode.weight) {
        goldWeightMilligrams = _parseGoldWeight(errors) ?? 0;
      } else {
        goldMonetaryValue = _parseAmount('goldValue', _goldValue, errors) ?? 0;
      }
    }

    if (_haul == null) {
      errors['haul'] = 'Pilih status haul sebelum menghitung.';
    }

    if (errors.isNotEmpty || price == null || _haul == null) {
      setState(() {
        _errors = errors;
        _formError = 'Beberapa bagian perlu diperiksa sebelum menghitung.';
      });
      return null;
    }

    final input = ZakatInput(
      goldPricePerGram: price,
      cash: cash,
      bankSavings: bankSavings,
      otherSavings: otherSavings,
      goldValueMode: _goldValueMode,
      goldWeightMilligrams: goldWeightMilligrams,
      goldMonetaryValue: goldMonetaryValue,
      goldPurpose: _goldPurpose,
      includePersonalJewelry: _includePersonalJewelry,
      tradeInventory: tradeInventory,
      tradeCash: tradeCash,
      tradeReceivables: tradeReceivables,
      haul: _haul!,
    );

    if (input.eligibleWealth > ZakatRules.maxEligibleWealth) {
      setState(() {
        _errors = errors;
        _formError = 'Total harta melebihi batas perhitungan.';
      });
      return null;
    }

    return input;
  }

  void _calculate() {
    FocusManager.instance.primaryFocus?.unfocus();
    final input = _collectInput();
    if (input == null) return;

    try {
      final result = ZakatCalculator.calculate(input);
      setState(() {
        _errors = <String, String>{};
        _formError = null;
        _result = result;
        _dirty = false;
      });
      _scrollToResult();
    } on ArgumentError {
      setState(() {
        _formError =
            'Nilai yang dimasukkan melebihi batas perhitungan. Periksa kembali '
            'harga emas dan nilai harta.';
      });
    }
  }

  void _reset() {
    FocusManager.instance.primaryFocus?.unfocus();
    for (final controller in <TextEditingController>[
      _goldPrice,
      _cash,
      _bankSavings,
      _otherSavings,
      _goldWeight,
      _goldValue,
      _tradeInventory,
      _tradeCash,
      _tradeReceivables,
    ]) {
      controller.clear();
    }
    setState(() {
      _goldValueMode = GoldValueMode.weight;
      _goldPurpose = GoldPurpose.storedInvestment;
      _includePersonalJewelry = false;
      _haul = null;
      _errors = <String, String>{};
      _formError = null;
      _result = null;
      _dirty = false;
    });
  }

  void _scrollToResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _resultKey.currentContext;
      if (target == null) return;
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        alignment: 0.03,
      );
    });
  }

  void _openReferences() {
    setState(() => _referencesExpanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _referencesKey.currentContext;
      if (target == null) return;
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final nisab = _nisabPreview;

    return PageScaffold(
      controller: _scrollController,
      child: Column(
        children: <Widget>[
          PageHeader(
            eyebrow: 'Zakat Maal',
            title: 'Hitung zakat dengan tenang.',
            description:
                'Perkirakan zakat atas kas, tabungan, emas, dan aset perdagangan. '
                'Nisab dihitung dari harga emas yang Anda masukkan, lalu hasilnya '
                'dijelaskan bersama asumsi dan dalilnya.',
            action: context.isMobile
                ? _HeaderDalilButton(onTap: _openReferences)
                : AppButton(
                    label: 'Dalil',
                    icon: Icons.menu_book_outlined,
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.compact,
                    semanticLabel: 'Buka dalil dan referensi zakat',
                    onPressed: _openReferences,
                  ),
            meta: const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                SoftBadge(label: 'Nisab 85 g emas', icon: Icons.scale_outlined),
                SoftBadge(label: 'Kadar 2,5%', icon: Icons.percent_rounded),
                SoftBadge(
                  label: 'Haul Hijriah',
                  icon: Icons.calendar_month_outlined,
                ),
              ],
            ),
          ),
          Container(
            color: palette.background,
            padding: context.sectionPadding,
            child: ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const _FormIntro(),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 1024;
                      final form = _buildForm(context);
                      final guide = _GuidePanel(nisab: nisab);
                      if (!wide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            form,
                            const SizedBox(height: 20),
                            guide,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(flex: 7, child: form),
                          const SizedBox(width: 24),
                          Expanded(flex: 4, child: guide),
                        ],
                      );
                    },
                  ),
                  if (_result != null) ...<Widget>[
                    const SizedBox(height: 42),
                    Container(
                      key: _resultKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (_dirty) ...<Widget>[
                            ZakatNotice(
                              title: 'Input berubah',
                              message:
                                  'Hasil di bawah masih memakai input sebelumnya. '
                                  'Tekan Hitung zakat lagi untuk memperbarui.',
                              tone: ZakatNoticeTone.caution,
                              icon: Icons.sync_problem_outlined,
                              trailing: AppTextLink(
                                label: 'Hitung ulang',
                                onTap: _calculate,
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                          ZakatResultSection(result: _result!),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 44),
                  ZakatReferences(
                    key: _referencesKey,
                    expanded: _referencesExpanded,
                    onToggle: () {
                      setState(
                        () => _referencesExpanded = !_referencesExpanded,
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const _DisclaimerPanel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 20 : 26),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildGoldPriceSection(context),
          _sectionDivider(context),
          _buildCashSection(context),
          _sectionDivider(context),
          _buildGoldSection(context),
          _sectionDivider(context),
          _buildTradeSection(context),
          _sectionDivider(context),
          _buildHaulSection(context),
          _sectionDivider(context),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildGoldPriceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const ZakatSectionHeader(
          number: '01',
          title: 'Harga emas & nisab',
          description:
              'Nisab zakat maal dihitung dari 85 gram emas. Masukkan harga emas '
              'per gram yang Anda gunakan hari ini.',
        ),
        const SizedBox(height: 16),
        ZakatAmountField(
          label: 'Harga emas per gram',
          controller: _goldPrice,
          required: true,
          errorText: _errors['goldPrice'],
          helperText:
              'Gunakan harga emas yang wajar dan dapat Anda pertanggungjawabkan.',
          onChanged: _onGoldPriceChanged,
        ),
        const SizedBox(height: 12),
        _NisabPreview(nisab: _nisabPreview),
      ],
    );
  }

  Widget _buildCashSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const ZakatSectionHeader(
          number: '02',
          title: 'Kas & tabungan',
          description:
              'Masukkan saldo yang benar-benar tersimpan, bukan seluruh '
              'penghasilan yang pernah diterima.',
        ),
        const SizedBox(height: 16),
        _ResponsiveFields(
          children: <Widget>[
            ZakatAmountField(
              label: 'Kas di tangan',
              controller: _cash,
              errorText: _errors['cash'],
              onChanged: (_) => _onFieldChanged('cash'),
            ),
            ZakatAmountField(
              label: 'Tabungan bank',
              controller: _bankSavings,
              errorText: _errors['bankSavings'],
              onChanged: (_) => _onFieldChanged('bankSavings'),
            ),
            ZakatAmountField(
              label: 'Tabungan lain',
              controller: _otherSavings,
              errorText: _errors['otherSavings'],
              helperText: 'Kosongkan jika tidak ada.',
              onChanged: (_) => _onFieldChanged('otherSavings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoldSection(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const ZakatSectionHeader(
          number: '03',
          title: 'Emas',
          description:
              'Masukkan emas tersimpan atau investasi. Perhiasan pribadi hanya '
              'dihitung bila Anda menyertakannya secara sadar.',
        ),
        const SizedBox(height: 16),
        ZakatSegmentedToggle<GoldValueMode>(
          value: _goldValueMode,
          onChanged: (mode) {
            setState(() => _goldValueMode = mode);
            _markDirty();
          },
          options: const <ZakatSegment<GoldValueMode>>[
            ZakatSegment<GoldValueMode>(
              value: GoldValueMode.weight,
              label: 'Berat emas',
              icon: Icons.scale_outlined,
            ),
            ZakatSegment<GoldValueMode>(
              value: GoldValueMode.monetaryValue,
              label: 'Nilai emas',
              icon: Icons.payments_outlined,
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_goldValueMode == GoldValueMode.weight)
          ZakatWeightField(
            controller: _goldWeight,
            errorText: _errors['goldWeight'],
            helperText:
                'Gunakan koma untuk desimal. Nilai emas dihitung dari harga per '
                'gram di bagian 01.',
            onChanged: (_) => _onFieldChanged('goldWeight'),
          )
        else
          ZakatAmountField(
            label: 'Nilai emas',
            controller: _goldValue,
            errorText: _errors['goldValue'],
            helperText: 'Masukkan taksiran nilai emas yang Anda miliki.',
            onChanged: (_) => _onFieldChanged('goldValue'),
          ),
        const SizedBox(height: 18),
        Text(
          'Jenis kepemilikan',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: palette.text,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Pilihan ini menentukan apakah emas masuk ke total harta.',
          style: TextStyle(fontSize: 11.5, height: 1.5, color: palette.muted),
        ),
        const SizedBox(height: 7),
        ZakatChoiceRow(
          title: 'Emas tersimpan atau investasi',
          subtitle: 'Emas batangan, koin, atau emas yang disimpan untuk nilai.',
          selected: _goldPurpose == GoldPurpose.storedInvestment,
          onTap: () {
            setState(() {
              _goldPurpose = GoldPurpose.storedInvestment;
              _includePersonalJewelry = false;
            });
            _markDirty();
          },
        ),
        ZakatChoiceRow(
          title: 'Perhiasan pribadi',
          subtitle:
              'Perhiasan yang dipakai sehari-hari. Tidak dihitung default.',
          selected: _goldPurpose == GoldPurpose.personalJewelry,
          onTap: () {
            setState(() => _goldPurpose = GoldPurpose.personalJewelry);
            _markDirty();
          },
        ),
        ZakatChoiceRow(
          title: 'Lainnya atau belum yakin',
          subtitle:
              'Status kepemilikan belum jelas. Tidak dimasukkan ke total.',
          selected: _goldPurpose == GoldPurpose.other,
          onTap: () {
            setState(() {
              _goldPurpose = GoldPurpose.other;
              _includePersonalJewelry = false;
            });
            _markDirty();
          },
        ),
        if (_goldPurpose == GoldPurpose.personalJewelry) ...<Widget>[
          const SizedBox(height: 10),
          _JewelryOptIn(
            value: _includePersonalJewelry,
            onChanged: (value) {
              setState(() => _includePersonalJewelry = value);
              _markDirty();
            },
          ),
        ],
        if (_goldPurpose == GoldPurpose.personalJewelry &&
            !_includePersonalJewelry) ...<Widget>[
          const SizedBox(height: 12),
          const ZakatNotice(
            title: 'Perhiasan pribadi tidak dihitung',
            message:
                'Sebagian ulama mewajibkan zakat perhiasan dan sebagian tidak. '
                'Aktifkan pilihan di atas hanya jika Anda mengikuti pendapat yang '
                'mewajibkannya. Emas perhiasan yang tidak disertakan tidak masuk '
                'ke total harta.',
            icon: Icons.info_outline_rounded,
          ),
        ],
        if (_goldPurpose == GoldPurpose.other) ...<Widget>[
          const SizedBox(height: 12),
          const ZakatNotice(
            title: 'Emas belum jelas tidak dihitung',
            message:
                'Tentukan status kepemilikan emas terlebih dahulu. Perhitungan ini '
                'tidak memasukkan emas yang statusnya belum dapat dipastikan.',
            tone: ZakatNoticeTone.caution,
            icon: Icons.help_outline_rounded,
          ),
        ],
      ],
    );
  }

  Widget _buildTradeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const ZakatSectionHeader(
          number: '04',
          title: 'Aset perdagangan',
          description:
              'Isi hanya bila Anda memiliki usaha dagang. Piutang dimasukkan '
              'sebatas yang diperkirakan benar-benar dapat ditagih.',
        ),
        const SizedBox(height: 16),
        _ResponsiveFields(
          children: <Widget>[
            ZakatAmountField(
              label: 'Persediaan dagang',
              controller: _tradeInventory,
              errorText: _errors['tradeInventory'],
              onChanged: (_) => _onFieldChanged('tradeInventory'),
            ),
            ZakatAmountField(
              label: 'Kas usaha',
              controller: _tradeCash,
              errorText: _errors['tradeCash'],
              onChanged: (_) => _onFieldChanged('tradeCash'),
            ),
            ZakatAmountField(
              label: 'Piutang tertagih',
              controller: _tradeReceivables,
              errorText: _errors['tradeReceivables'],
              onChanged: (_) => _onFieldChanged('tradeReceivables'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const ZakatNotice(
          title: 'Utang tidak dikurangkan otomatis',
          message:
              'Kalkulator ini tidak mengurangi utang dari total harta. Jika Anda '
              'ingin memperhitungkan utang, konsultasikan lebih dahulu dengan ahli '
              'atau lembaga zakat terpercaya.',
          tone: ZakatNoticeTone.caution,
          icon: Icons.account_balance_wallet_outlined,
        ),
      ],
    );
  }

  Widget _buildHaulSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const ZakatSectionHeader(
          number: '05',
          title: 'Haul',
          description:
              'Haul adalah kepemilikan harta selama satu tahun Hijriah. Hasil '
              'hanya dianggap kewajiban bila nisab dan haul sama-sama terpenuhi.',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final threeColumns = constraints.maxWidth >= 620;
            final width = threeColumns
                ? (constraints.maxWidth - 20) / 3
                : constraints.maxWidth;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                SizedBox(
                  width: width,
                  child: ZakatHaulOption(
                    title: 'Sudah terpenuhi',
                    subtitle: 'Harta telah dimiliki satu tahun Hijriah penuh.',
                    selected: _haul == HaulStatus.fulfilled,
                    hasError: _errors.containsKey('haul'),
                    onTap: () {
                      setState(() {
                        _haul = HaulStatus.fulfilled;
                        _errors = <String, String>{..._errors}..remove('haul');
                        _formError = null;
                      });
                      _markDirty();
                    },
                  ),
                ),
                SizedBox(
                  width: width,
                  child: ZakatHaulOption(
                    title: 'Belum terpenuhi',
                    subtitle: 'Harta belum genap satu tahun Hijriah.',
                    selected: _haul == HaulStatus.notFulfilled,
                    hasError: _errors.containsKey('haul'),
                    onTap: () {
                      setState(() {
                        _haul = HaulStatus.notFulfilled;
                        _errors = <String, String>{..._errors}..remove('haul');
                        _formError = null;
                      });
                      _markDirty();
                    },
                  ),
                ),
                SizedBox(
                  width: width,
                  child: ZakatHaulOption(
                    title: 'Belum yakin',
                    subtitle: 'Tanggal kepemilikan belum dapat dipastikan.',
                    selected: _haul == HaulStatus.unsure,
                    hasError: _errors.containsKey('haul'),
                    onTap: () {
                      setState(() {
                        _haul = HaulStatus.unsure;
                        _errors = <String, String>{..._errors}..remove('haul');
                        _formError = null;
                      });
                      _markDirty();
                    },
                  ),
                ),
              ],
            );
          },
        ),
        if (_errors['haul'] != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            _errors['haul']!,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_formError != null) ...<Widget>[
          Text(
            _formError!,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 12),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 390;
            final calculate = AppButton(
              label: 'Hitung zakat',
              icon: Icons.calculate_outlined,
              expand: !wide,
              onPressed: _calculate,
            );
            final reset = AppButton(
              label: 'Reset',
              variant: AppButtonVariant.ghost,
              expand: !wide,
              onPressed: _reset,
            );
            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[calculate, const SizedBox(height: 8), reset],
              );
            }
            return Row(
              children: <Widget>[
                calculate,
                const SizedBox(width: 10),
                reset,
                const Spacer(),
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: palette.muted,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Dihitung di perangkat Anda',
                    style: TextStyle(fontSize: 11.5, color: palette.muted),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _sectionDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(height: 1, color: context.palette.border),
    );
  }
}

class _HeaderDalilButton extends StatelessWidget {
  const _HeaderDalilButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Tooltip(
      message: 'Dalil & referensi',
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        label: 'Buka dalil dan referensi zakat',
        onTap: onTap,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 26,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.6),
              shape: BoxShape.circle,
              border: Border.all(color: palette.border),
            ),
            child: Icon(
              Icons.menu_book_outlined,
              size: 20,
              color: palette.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _FormIntro extends StatelessWidget {
  const _FormIntro();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.edit_note_rounded, size: 18, color: palette.gold),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            'Isi bagian yang relevan. Kolom harta yang tidak Anda miliki boleh '
            'dikosongkan; harga emas dan status haul tetap diperlukan.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.55,
              color: palette.muted,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 520;
        final width = twoColumns
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: <Widget>[
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class _NisabPreview extends StatelessWidget {
  const _NisabPreview({required this.nisab});

  final int? nisab;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final available = nisab != null;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: palette.primarySoft.withValues(
          alpha: context.isDarkMode ? 0.42 : 0.58,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: palette.primary.withValues(
            alpha: context.isDarkMode ? 0.26 : 0.16,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.scale_outlined, size: 16, color: palette.primary),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Nisab saat ini',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: palette.muted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  available ? formatRupiah(nisab!) : 'Menunggu harga emas',
                  style: TextStyle(
                    fontSize: available ? 16 : 13,
                    fontWeight: available ? FontWeight.w700 : FontWeight.w500,
                    color: available ? palette.primary : palette.muted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  available
                      ? '85 gram × harga emas per gram.'
                      : 'Masukkan harga emas untuk melihat ambang nisab.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.45,
                    color: palette.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JewelryOptIn extends StatelessWidget {
  const _JewelryOptIn({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      checked: value,
      label:
          'Sertakan perhiasan pribadi. Saya memahami bahwa sebagian ulama '
          'mewajibkan zakat perhiasan dan memilih untuk menyertakannya dalam hitungan.',
      onTap: () => onChanged(!value),
      excludeSemantics: true,
      child: Material(
        color: palette.surfaceAlt.withValues(
          alpha: context.isDarkMode ? 0.5 : 0.55,
        ),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                IgnorePointer(
                  child: ExcludeSemantics(
                    child: Checkbox(
                      value: value,
                      onChanged: (_) {},
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Sertakan perhiasan pribadi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: palette.text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Saya memahami bahwa sebagian ulama mewajibkan zakat '
                        'perhiasan dan memilih untuk menyertakannya dalam hitungan.',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.5,
                          color: palette.muted,
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
}

class _GuidePanel extends StatelessWidget {
  const _GuidePanel({required this.nisab});

  final int? nisab;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(
          alpha: context.isDarkMode ? 0.5 : 0.5,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 33,
                height: 33,
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: palette.border),
                ),
                child: Icon(
                  Icons.route_outlined,
                  size: 17,
                  color: palette.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kerangka perhitungan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _GuideStep(
            number: '01',
            title: 'Nisab',
            value: nisab == null ? '85 g emas' : formatRupiah(nisab!),
            note: 'Harta di bawah ambang ini belum dizakati.',
          ),
          _GuideStep(
            number: '02',
            title: 'Haul',
            value: '1 tahun Hijriah',
            note: 'Kepemilikan harta harus genap satu tahun.',
          ),
          _GuideStep(
            number: '03',
            title: 'Kadar zakat',
            value: '2,5%',
            note: 'Dihitung dari harta yang memenuhi syarat.',
            isLast: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: palette.border),
          ),
          Text(
            'Tidak dihitung otomatis',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: palette.muted,
            ),
          ),
          const SizedBox(height: 8),
          for (final item in const <String>[
            'Utang dan kewajiban usaha.',
            'Perhiasan pribadi tanpa persetujuan Anda.',
            'Emas dengan status kepemilikan yang belum jelas.',
            'Piutang yang diperkirakan sulit ditagih.',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: palette.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.55,
                        color: palette.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'Kalkulator ini memakai satu metode yang dinyatakan terbuka. '
            'Perbedaan pendapat fiqh tetap perlu Anda konsultasikan.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.55,
              color: palette.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.number,
    required this.title,
    required this.value,
    required this.note,
    this.isLast = false,
  });

  final String number;
  final String title;
  final String value;
  final String note;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            number,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: palette.gold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: palette.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: palette.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.45,
                    color: palette.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerPanel extends StatelessWidget {
  const _DisclaimerPanel();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface.withValues(
          alpha: context.isDarkMode ? 0.7 : 0.62,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.gavel_outlined, size: 18, color: palette.gold),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Batas penggunaan',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: palette.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Hasil ini adalah perkiraan, bukan fatwa dan bukan pengganti '
            'konsultasi dengan ulama atau lembaga zakat. Kalkulator memakai nisab '
            '85 gram emas, kadar 2,5%, dan haul satu tahun Hijriah sesuai input '
            'Anda. Utang tidak dikurangkan otomatis. Periksa kembali tanggal '
            'kepemilikan harta dan kondisi aset sebelum menunaikan zakat. '
            'Pembayaran dilakukan di luar Bitaqwa.',
            style: TextStyle(fontSize: 12, height: 1.65, color: palette.muted),
          ),
        ],
      ),
    );
  }
}
