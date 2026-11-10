import 'zakat_rules.dart';

/// Whether the wealth has completed one Hijri year (haul).
enum HaulStatus { fulfilled, notFulfilled, unsure }

/// Why the user owns the gold. This controls whether it enters the total.
enum GoldPurpose { storedInvestment, personalJewelry, other }

/// How the user entered their gold: physical weight or monetary value.
enum GoldValueMode { weight, monetaryValue }

enum ZakatStatus { due, belowNisab, haulNotFulfilled, haulUnknown }

/// Validated inputs for one Zakat Maal calculation.
///
/// Monetary values are whole Rupiah. Gold weight is stored in milligrams so
/// that decimal gram inputs convert to Rupiah deterministically.
class ZakatInput {
  const ZakatInput({
    required this.goldPricePerGram,
    required this.cash,
    required this.bankSavings,
    required this.otherSavings,
    required this.goldValueMode,
    required this.goldWeightMilligrams,
    required this.goldMonetaryValue,
    required this.goldPurpose,
    required this.includePersonalJewelry,
    required this.tradeInventory,
    required this.tradeCash,
    required this.tradeReceivables,
    required this.haul,
  });

  final int goldPricePerGram;
  final int cash;
  final int bankSavings;
  final int otherSavings;

  final GoldValueMode goldValueMode;
  final int goldWeightMilligrams;
  final int goldMonetaryValue;
  final GoldPurpose goldPurpose;
  final bool includePersonalJewelry;

  final int tradeInventory;
  final int tradeCash;
  final int tradeReceivables;

  final HaulStatus haul;

  int get cashTotal => cash + bankSavings + otherSavings;

  int get tradeTotal => tradeInventory + tradeCash + tradeReceivables;

  bool get goldIncluded {
    return switch (goldPurpose) {
      GoldPurpose.storedInvestment => true,
      GoldPurpose.personalJewelry => includePersonalJewelry,
      GoldPurpose.other => false,
    };
  }

  int get goldTotal {
    if (!goldIncluded) return 0;
    if (goldValueMode == GoldValueMode.weight) {
      return ZakatRules.goldValueForWeightMilligrams(
        milligrams: goldWeightMilligrams,
        pricePerGram: goldPricePerGram,
      );
    }
    return goldMonetaryValue;
  }

  int get eligibleWealth => cashTotal + goldTotal + tradeTotal;
}

/// The transparent output of a calculation. [zakatAmount] is zero whenever
/// the selected assumptions do not establish an obligation.
class ZakatResult {
  const ZakatResult({
    required this.status,
    required this.input,
    required this.eligibleWealth,
    required this.nisab,
    required this.cashTotal,
    required this.goldTotal,
    required this.tradeTotal,
    required this.zakatAmount,
    required this.estimatedIfDue,
    required this.goldPricePerGram,
    required this.goldPurpose,
    required this.goldIncluded,
    required this.haul,
  });

  final ZakatStatus status;

  /// The validated inputs behind this result, kept for the detailed breakdown.
  final ZakatInput input;
  final int eligibleWealth;
  final int nisab;
  final int cashTotal;
  final int goldTotal;
  final int tradeTotal;
  final int zakatAmount;
  final int estimatedIfDue;
  final int goldPricePerGram;
  final GoldPurpose goldPurpose;
  final bool goldIncluded;
  final HaulStatus haul;

  bool get isDue => status == ZakatStatus.due;

  int get nisabShortfall {
    final difference = nisab - eligibleWealth;
    return difference > 0 ? difference : 0;
  }
}
