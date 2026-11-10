import 'package:bitaqwa/core/utils/formatters.dart';
import 'package:bitaqwa/features/zakat/domain/zakat_calculator.dart';
import 'package:bitaqwa/features/zakat/domain/zakat_models.dart';
import 'package:bitaqwa/features/zakat/domain/zakat_parsing.dart';
import 'package:bitaqwa/features/zakat/domain/zakat_rules.dart';
import 'package:bitaqwa/features/zakat/presentation/widgets/zakat_fields.dart';
import 'package:flutter_test/flutter_test.dart';

ZakatInput _input({
  int goldPricePerGram = 1500000,
  int cash = 0,
  int bankSavings = 0,
  int otherSavings = 0,
  GoldValueMode goldValueMode = GoldValueMode.weight,
  int goldWeightMilligrams = 0,
  int goldMonetaryValue = 0,
  GoldPurpose goldPurpose = GoldPurpose.storedInvestment,
  bool includePersonalJewelry = false,
  int tradeInventory = 0,
  int tradeCash = 0,
  int tradeReceivables = 0,
  HaulStatus haul = HaulStatus.fulfilled,
}) {
  return ZakatInput(
    goldPricePerGram: goldPricePerGram,
    cash: cash,
    bankSavings: bankSavings,
    otherSavings: otherSavings,
    goldValueMode: goldValueMode,
    goldWeightMilligrams: goldWeightMilligrams,
    goldMonetaryValue: goldMonetaryValue,
    goldPurpose: goldPurpose,
    includePersonalJewelry: includePersonalJewelry,
    tradeInventory: tradeInventory,
    tradeCash: tradeCash,
    tradeReceivables: tradeReceivables,
    haul: haul,
  );
}

void main() {
  group('nisab and status', () {
    test('wealth below nisab is not due', () {
      final result = ZakatCalculator.calculate(_input(cash: 100000000));

      expect(result.nisab, 127500000);
      expect(result.eligibleWealth, 100000000);
      expect(result.status, ZakatStatus.belowNisab);
      expect(result.zakatAmount, 0);
      expect(result.nisabShortfall, 27500000);
    });

    test('wealth exactly at nisab is due', () {
      final result = ZakatCalculator.calculate(_input(cash: 127500000));

      expect(result.eligibleWealth, result.nisab);
      expect(result.status, ZakatStatus.due);
      expect(result.zakatAmount, 3187500);
      expect(result.nisabShortfall, 0);
    });

    test('wealth above nisab is due', () {
      final result = ZakatCalculator.calculate(_input(cash: 200000000));

      expect(result.status, ZakatStatus.due);
      expect(result.zakatAmount, 5000000);
      expect(result.estimatedIfDue, 5000000);
    });

    test('nisab is always 85 grams of the user supplied gold price', () {
      expect(ZakatRules.nisabFor(1000000), 85000000);
      expect(ZakatRules.nisabFor(1650000), 140250000);
    });

    test('empty and zero inputs do not create an obligation', () {
      final result = ZakatCalculator.calculate(_input());

      expect(result.eligibleWealth, 0);
      expect(result.status, ZakatStatus.belowNisab);
      expect(result.zakatAmount, 0);
      expect(result.estimatedIfDue, 0);
    });
  });

  group('haul', () {
    test('haul not fulfilled is not calculated as due', () {
      final result = ZakatCalculator.calculate(
        _input(cash: 200000000, haul: HaulStatus.notFulfilled),
      );

      expect(result.status, ZakatStatus.haulNotFulfilled);
      expect(result.zakatAmount, 0);
      expect(result.estimatedIfDue, 5000000);
    });

    test('unknown haul is not labelled as an obligation', () {
      final result = ZakatCalculator.calculate(
        _input(cash: 200000000, haul: HaulStatus.unsure),
      );

      expect(result.status, ZakatStatus.haulUnknown);
      expect(result.zakatAmount, 0);
      expect(result.estimatedIfDue, 5000000);
    });

    test('below nisab stays below nisab even when haul is not fulfilled', () {
      final result = ZakatCalculator.calculate(
        _input(cash: 50000000, haul: HaulStatus.notFulfilled),
      );

      expect(result.status, ZakatStatus.belowNisab);
      expect(result.zakatAmount, 0);
    });

    test('nisab reached does not bypass a missing haul', () {
      final result = ZakatCalculator.calculate(
        _input(cash: 127500000, haul: HaulStatus.notFulfilled),
      );

      expect(result.eligibleWealth, result.nisab);
      expect(result.nisabShortfall, 0);
      expect(result.status, ZakatStatus.haulNotFulfilled);
      expect(result.zakatAmount, 0);
      expect(result.estimatedIfDue, 3187500);
    });
  });

  group('assets', () {
    test('combines cash, savings, gold, and trade assets', () {
      final result = ZakatCalculator.calculate(
        _input(
          cash: 50000000,
          bankSavings: 25000000,
          otherSavings: 5000000,
          goldWeightMilligrams: 10000,
          tradeInventory: 30000000,
          tradeCash: 5000000,
          tradeReceivables: 5000000,
        ),
      );

      expect(result.cashTotal, 80000000);
      expect(result.goldTotal, 15000000);
      expect(result.tradeTotal, 40000000);
      expect(result.eligibleWealth, 135000000);
      expect(result.status, ZakatStatus.due);
      expect(result.zakatAmount, 3375000);
    });

    test('trade totals stay gross because no liability is deducted', () {
      final result = ZakatCalculator.calculate(
        _input(
          tradeInventory: 200000000,
          tradeCash: 50000000,
          tradeReceivables: 25000000,
        ),
      );

      expect(result.tradeTotal, 275000000);
      expect(result.eligibleWealth, 275000000);
      expect(result.zakatAmount, 6875000);
    });

    test('gold entered as monetary value is included directly', () {
      final result = ZakatCalculator.calculate(
        _input(
          goldValueMode: GoldValueMode.monetaryValue,
          goldMonetaryValue: 200000000,
        ),
      );

      expect(result.goldTotal, 200000000);
      expect(result.status, ZakatStatus.due);
      expect(result.zakatAmount, 5000000);
    });

    test('stored gold converts grams using the supplied price', () {
      final result = ZakatCalculator.calculate(
        _input(goldWeightMilligrams: 12500, goldPricePerGram: 1600000),
      );

      expect(result.goldTotal, 20000000);
      expect(result.eligibleWealth, 20000000);
    });

    test('personal jewelry is excluded by default', () {
      final result = ZakatCalculator.calculate(
        _input(
          goldWeightMilligrams: 100000,
          goldPurpose: GoldPurpose.personalJewelry,
        ),
      );

      expect(result.goldIncluded, isFalse);
      expect(result.goldTotal, 0);
      expect(result.status, ZakatStatus.belowNisab);
    });

    test('personal jewelry is included only after explicit opt-in', () {
      final result = ZakatCalculator.calculate(
        _input(
          goldWeightMilligrams: 100000,
          goldPurpose: GoldPurpose.personalJewelry,
          includePersonalJewelry: true,
        ),
      );

      expect(result.goldIncluded, isTrue);
      expect(result.goldTotal, 150000000);
      expect(result.status, ZakatStatus.due);
      expect(result.zakatAmount, 3750000);
    });

    test('gold with unclear status is excluded from the total', () {
      final result = ZakatCalculator.calculate(
        _input(goldWeightMilligrams: 100000, goldPurpose: GoldPurpose.other),
      );

      expect(result.goldIncluded, isFalse);
      expect(result.goldTotal, 0);
    });

    test('unclear gold stays excluded even if the jewelry flag is true', () {
      final result = ZakatCalculator.calculate(
        _input(
          goldWeightMilligrams: 100000,
          goldPurpose: GoldPurpose.other,
          includePersonalJewelry: true,
        ),
      );

      expect(result.goldIncluded, isFalse);
      expect(result.goldTotal, 0);
      expect(result.status, ZakatStatus.belowNisab);
    });

    test('monetary personal jewelry is excluded by default', () {
      final result = ZakatCalculator.calculate(
        _input(
          goldValueMode: GoldValueMode.monetaryValue,
          goldMonetaryValue: 200000000,
          goldPurpose: GoldPurpose.personalJewelry,
        ),
      );

      expect(result.goldIncluded, isFalse);
      expect(result.goldTotal, 0);
      expect(result.eligibleWealth, 0);
      expect(result.status, ZakatStatus.belowNisab);
    });

    test('monetary personal jewelry requires explicit opt-in', () {
      final result = ZakatCalculator.calculate(
        _input(
          goldValueMode: GoldValueMode.monetaryValue,
          goldMonetaryValue: 200000000,
          goldPurpose: GoldPurpose.personalJewelry,
          includePersonalJewelry: true,
        ),
      );

      expect(result.goldIncluded, isTrue);
      expect(result.goldTotal, 200000000);
      expect(result.status, ZakatStatus.due);
      expect(result.zakatAmount, 5000000);
    });
  });

  group('rounding and conversion', () {
    test('applies exactly 2.5 percent', () {
      expect(ZakatRules.zakatFor(200000000), 5000000);
      expect(ZakatRules.zakatFor(100000000), 2500000);
    });

    test('rounds Rupiah half-up', () {
      expect(ZakatRules.zakatFor(100020), 2501);
      expect(ZakatRules.zakatFor(123456), 3086);
      expect(ZakatRules.zakatFor(123457), 3086);
    });

    test('converts decimal gram weights deterministically', () {
      expect(
        ZakatRules.goldValueForWeightMilligrams(
          milligrams: 12345,
          pricePerGram: 1500000,
        ),
        18517500,
      );
      expect(
        ZakatRules.goldValueForWeightMilligrams(
          milligrams: 1,
          pricePerGram: 1500,
        ),
        2,
      );
    });

    test('parses Indonesian and plain decimal separators', () {
      expect(ZakatParsing.parseRupiah('Rp127.500.000'), 127500000);
      expect(ZakatParsing.parseRupiah('Rp 127.500.000'), 127500000);
      expect(ZakatParsing.parseRupiah(''), isNull);
      expect(ZakatParsing.parseRupiah('-100'), isNull);
      expect(ZakatParsing.parseRupiah('12abc'), isNull);
      expect(ZakatParsing.parseRupiah('127,500'), isNull);

      expect(ZakatParsing.parseGoldWeightMilligrams('12,5'), 12500);
      expect(ZakatParsing.parseGoldWeightMilligrams('12.5'), 12500);
      expect(ZakatParsing.parseGoldWeightMilligrams('0,001'), 1);
      expect(ZakatParsing.parseGoldWeightMilligrams('12,3456'), isNull);
      expect(ZakatParsing.parseGoldWeightMilligrams('12,5,1'), isNull);
    });
  });

  group('validation guards', () {
    test('rejects negative monetary values', () {
      expect(
        () => ZakatCalculator.calculate(_input(cash: -1)),
        throwsArgumentError,
      );
      expect(
        () => ZakatCalculator.calculate(_input(bankSavings: -1)),
        throwsArgumentError,
      );
      expect(
        () => ZakatCalculator.calculate(_input(tradeReceivables: -1)),
        throwsArgumentError,
      );
    });

    test('rejects a missing or zero gold price', () {
      expect(
        () => ZakatCalculator.calculate(_input(goldPricePerGram: 0)),
        throwsArgumentError,
      );
    });

    test('rejects excessively large values', () {
      expect(
        () => ZakatCalculator.calculate(
          _input(goldPricePerGram: ZakatRules.maxGoldPricePerGram + 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => ZakatCalculator.calculate(_input(cash: ZakatRules.maxRupiah + 1)),
        throwsArgumentError,
      );
      expect(
        () => ZakatCalculator.calculate(
          _input(goldWeightMilligrams: ZakatRules.maxGoldWeightMilligrams + 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => ZakatCalculator.calculate(_input(goldWeightMilligrams: -1)),
        throwsArgumentError,
      );
      expect(
        () => ZakatCalculator.calculate(
          _input(
            goldPricePerGram: ZakatRules.maxGoldPricePerGram,
            goldWeightMilligrams: ZakatRules.maxGoldWeightMilligrams,
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('currency formatting', () {
    test('formats integer Rupiah consistently', () {
      expect(formatRupiah(3187500), 'Rp3.187.500');
      expect(formatRupiah(0), 'Rp0');
      expect(formatRupiah(127500000), 'Rp127.500.000');
    });

    test('formats milligram weights as Indonesian grams', () {
      expect(formatGoldGrams(1000000), '1.000 g');
      expect(formatGoldGrams(12500), '12,5 g');
      expect(formatGoldGrams(1), '0,001 g');
    });
  });

  group('input formatters', () {
    test('rejects negative pasted Rupiah amounts', () {
      final formatter = RupiahInputFormatter();
      const oldValue = TextEditingValue(text: '100.000');

      expect(
        formatter
            .formatEditUpdate(
              oldValue,
              const TextEditingValue(text: '-100.000'),
            )
            .text,
        '100.000',
      );
      expect(
        formatter
            .formatEditUpdate(
              TextEditingValue.empty,
              const TextEditingValue(text: '-100'),
            )
            .text,
        isEmpty,
      );
    });

    test('rejects negative pasted gold weights', () {
      const formatter = GoldWeightInputFormatter();
      const oldValue = TextEditingValue(text: '12,5');

      expect(
        formatter
            .formatEditUpdate(oldValue, const TextEditingValue(text: '-12,5'))
            .text,
        '12,5',
      );
    });
  });
}
