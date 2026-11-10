import '../domain/zakat_models.dart';

String haulLabel(HaulStatus status) {
  return switch (status) {
    HaulStatus.fulfilled => 'Sudah terpenuhi',
    HaulStatus.notFulfilled => 'Belum terpenuhi',
    HaulStatus.unsure => 'Belum yakin',
  };
}

String haulShortLabel(HaulStatus? status) {
  return switch (status) {
    HaulStatus.fulfilled => 'Sudah',
    HaulStatus.notFulfilled => 'Belum',
    HaulStatus.unsure => 'Belum yakin',
    null => 'Belum dipilih',
  };
}

String goldPurposeLabel(GoldPurpose purpose) {
  return switch (purpose) {
    GoldPurpose.storedInvestment => 'Emas tersimpan atau investasi',
    GoldPurpose.personalJewelry => 'Perhiasan pribadi',
    GoldPurpose.other => 'Lainnya atau belum yakin',
  };
}
