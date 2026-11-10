/// Fixed assumptions used by the Zakat Maal MVP.
///
/// These values are intentionally centralised so the calculation and the
/// educational copy cannot drift apart. They describe the selected method,
/// not a universal fatwa.
abstract final class ZakatRules {
  /// Nisab for monetary wealth, expressed as the value of 85 grams of gold.
  static const int nisabGoldGrams = 85;

  /// Zakat rate: 2.5%, represented as 25/1000 for integer rounding.
  static const int zakatNumerator = 25;
  static const int zakatDenominator = 1000;

  /// Sensible guards for a web calculator. They are far above realistic
  /// personal wealth values and keep arithmetic deterministic.
  static const int maxRupiah = 1000000000000;
  static const int maxEligibleWealth = 10000000000000;
  static const int maxGoldPricePerGram = 1000000000;
  static const int milligramsPerGram = 1000;
  static const int maxGoldWeightMilligrams = 1000000000;

  static int nisabFor(int goldPricePerGram) =>
      goldPricePerGram * nisabGoldGrams;

  /// Converts a weight in milligrams to Rupiah, rounded to the nearest Rupiah.
  static int goldValueForWeightMilligrams({
    required int milligrams,
    required int pricePerGram,
  }) {
    return (milligrams * pricePerGram + 500) ~/ 1000;
  }

  /// 2.5% of [wealth], rounded half-up to the nearest Rupiah.
  static int zakatFor(int wealth) {
    return (wealth * zakatNumerator + 500) ~/ zakatDenominator;
  }
}
