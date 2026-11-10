import 'zakat_models.dart';
import 'zakat_rules.dart';

/// Pure Zakat Maal calculation. Keeping this independent from widgets makes
/// every rule testable and prevents presentation details from changing results.
abstract final class ZakatCalculator {
  static ZakatResult calculate(ZakatInput input) {
    _validate(input);

    final nisab = ZakatRules.nisabFor(input.goldPricePerGram);
    final eligibleWealth = input.eligibleWealth;
    final estimatedIfDue = ZakatRules.zakatFor(eligibleWealth);

    final status = switch (input.haul) {
      HaulStatus.fulfilled when eligibleWealth < nisab =>
        ZakatStatus.belowNisab,
      HaulStatus.fulfilled => ZakatStatus.due,
      HaulStatus.notFulfilled when eligibleWealth < nisab =>
        ZakatStatus.belowNisab,
      HaulStatus.notFulfilled => ZakatStatus.haulNotFulfilled,
      HaulStatus.unsure when eligibleWealth < nisab => ZakatStatus.belowNisab,
      HaulStatus.unsure => ZakatStatus.haulUnknown,
    };

    return ZakatResult(
      status: status,
      input: input,
      eligibleWealth: eligibleWealth,
      nisab: nisab,
      cashTotal: input.cashTotal,
      goldTotal: input.goldTotal,
      tradeTotal: input.tradeTotal,
      zakatAmount: status == ZakatStatus.due ? estimatedIfDue : 0,
      estimatedIfDue: estimatedIfDue,
      goldPricePerGram: input.goldPricePerGram,
      goldPurpose: input.goldPurpose,
      goldIncluded: input.goldIncluded,
      haul: input.haul,
    );
  }

  static void _validate(ZakatInput input) {
    if (input.goldPricePerGram <= 0) {
      throw ArgumentError.value(
        input.goldPricePerGram,
        'goldPricePerGram',
        'Harga emas harus lebih dari 0.',
      );
    }
    if (input.goldPricePerGram > ZakatRules.maxGoldPricePerGram) {
      throw ArgumentError.value(
        input.goldPricePerGram,
        'goldPricePerGram',
        'Harga emas melebihi batas perhitungan.',
      );
    }

    _validateRupiah(input.cash, 'cash');
    _validateRupiah(input.bankSavings, 'bankSavings');
    _validateRupiah(input.otherSavings, 'otherSavings');
    _validateRupiah(input.goldMonetaryValue, 'goldMonetaryValue');
    _validateRupiah(input.tradeInventory, 'tradeInventory');
    _validateRupiah(input.tradeCash, 'tradeCash');
    _validateRupiah(input.tradeReceivables, 'tradeReceivables');

    if (input.goldWeightMilligrams < 0) {
      throw ArgumentError.value(
        input.goldWeightMilligrams,
        'goldWeightMilligrams',
        'Berat emas tidak boleh negatif.',
      );
    }
    if (input.goldWeightMilligrams > ZakatRules.maxGoldWeightMilligrams) {
      throw ArgumentError.value(
        input.goldWeightMilligrams,
        'goldWeightMilligrams',
        'Berat emas melebihi batas perhitungan.',
      );
    }

    if (input.goldTotal > ZakatRules.maxRupiah) {
      throw ArgumentError.value(
        input.goldTotal,
        'goldTotal',
        'Nilai emas melebihi batas perhitungan.',
      );
    }
    if (input.eligibleWealth > ZakatRules.maxEligibleWealth) {
      throw ArgumentError.value(
        input.eligibleWealth,
        'eligibleWealth',
        'Total harta melebihi batas perhitungan.',
      );
    }
  }

  static void _validateRupiah(int value, String name) {
    if (value < 0) {
      throw ArgumentError.value(value, name, 'Nilai tidak boleh negatif.');
    }
    if (value > ZakatRules.maxRupiah) {
      throw ArgumentError.value(
        value,
        name,
        'Nilai melebihi batas perhitungan.',
      );
    }
  }
}
