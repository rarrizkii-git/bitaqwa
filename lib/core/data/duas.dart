import '../models/dua.dart';

abstract final class Duas {
  static const all = <Dua>[
    Dua(
      id: 'bangun-tidur',
      title: 'Doa Bangun Tidur',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      latin: "Alhamdulillahilladzi ahyana ba'da ma amatana wa ilaihin nusyur.",
      translation:
          'Segala puji bagi Allah yang telah menghidupkan kami setelah mematikan kami, dan kepada-Nya kami dikembalikan.',
      source: 'HR. Bukhari no. 6312',
      category: DuaCategory.harian,
    ),
    Dua(
      id: 'sebelum-tidur',
      title: 'Doa Sebelum Tidur',
      arabic: 'بِسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      latin: 'Bismika Allahumma amutu wa ahya.',
      translation: 'Dengan nama-Mu ya Allah, aku mati dan aku hidup.',
      source: 'HR. Bukhari no. 6324',
      category: DuaCategory.harian,
    ),
    Dua(
      id: 'sebelum-makan',
      title: 'Doa Sebelum Makan',
      arabic: 'بِسْمِ اللَّهِ',
      latin: 'Bismillah.',
      translation: 'Dengan menyebut nama Allah.',
      source: 'HR. Bukhari no. 5376; Muslim no. 2022',
      category: DuaCategory.harian,
      note:
          'Jika lupa mengucapkannya di awal, ucapkan: Bismillahi awwalahu wa akhirahu. (HR. Abu Dawud no. 3767)',
    ),
    Dua(
      id: 'setelah-makan',
      title: 'Doa Setelah Makan',
      arabic:
          'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
      latin:
          "Alhamdulillahilladzi ath'amana wa saqana wa ja'alana muslimin.",
      translation:
          'Segala puji bagi Allah yang telah memberi kami makan dan minum serta menjadikan kami sebagai muslim.',
      source: 'HR. Abu Dawud no. 3850; Tirmidzi no. 3457 (hasan)',
      category: DuaCategory.harian,
    ),
    Dua(
      id: 'masuk-masjid',
      title: 'Doa Masuk Masjid',
      arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
      latin: 'Allahummaftah li abwaba rahmatik.',
      translation: 'Ya Allah, bukakanlah untukku pintu-pintu rahmat-Mu.',
      source: 'HR. Muslim no. 713',
      category: DuaCategory.ibadah,
    ),
    Dua(
      id: 'keluar-masjid',
      title: 'Doa Keluar Masjid',
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
      latin: "Allahumma inni as'aluka min fadhlik.",
      translation:
          'Ya Allah, sesungguhnya aku memohon kepada-Mu sebagian dari karunia-Mu.',
      source: 'HR. Muslim no. 713',
      category: DuaCategory.ibadah,
    ),
    Dua(
      id: 'keluar-rumah',
      title: 'Doa Keluar Rumah',
      arabic:
          'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      latin:
          "Bismillahi tawakkaltu 'alallahi la hawla wa la quwwata illa billah.",
      translation:
          'Dengan nama Allah, aku bertawakal kepada Allah. Tidak ada daya dan kekuatan kecuali dengan Allah.',
      source: 'HR. Abu Dawud no. 5095; Tirmidzi no. 3426',
      category: DuaCategory.perlindungan,
    ),
    Dua(
      id: 'masuk-rumah',
      title: 'Doa Masuk Rumah',
      arabic:
          'بِسْمِ اللَّهِ وَلَجْنَا وَبِسْمِ اللَّهِ خَرَجْنَا وَعَلَى رَبِّنَا تَوَكَّلْنَا',
      latin:
          "Bismillahi walajna wa bismillahi kharajna wa 'ala rabbina tawakkalna.",
      translation:
          'Dengan nama Allah kami masuk, dengan nama Allah kami keluar, dan kepada Tuhan kami kami bertawakal.',
      source: 'HR. Abu Dawud no. 5096',
      category: DuaCategory.perlindungan,
    ),
    Dua(
      id: 'naik-kendaraan',
      title: 'Doa Naik Kendaraan',
      arabic:
          'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
      latin:
          'Subhanalladzi sakhkhara lana hadza wa ma kunna lahu muqrinin wa inna ila rabbina lamunqalibun.',
      translation:
          'Maha Suci Allah yang telah menundukkan kendaraan ini bagi kami, padahal kami tidak mampu menguasainya. Dan sesungguhnya kepada Tuhan kami, kami akan kembali.',
      source: 'QS. Az-Zukhruf: 13–14; HR. Muslim no. 1342',
      category: DuaCategory.perjalanan,
    ),
    Dua(
      id: 'orang-tua',
      title: 'Doa untuk Orang Tua',
      arabic: 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      latin: 'Rabbirhamhuma kama rabbayani shaghira.',
      translation:
          'Tuhanku, sayangilah keduanya sebagaimana mereka menyayangiku ketika aku masih kecil.',
      source: 'QS. Al-Isra: 24',
      category: DuaCategory.keluarga,
    ),
    Dua(
      id: 'dunia-akhirat',
      title: 'Doa Kebaikan Dunia dan Akhirat',
      arabic:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      latin:
          "Rabbana atina fid-dunya hasanah wa fil-akhirati hasanah wa qina 'adzabannar.",
      translation:
          'Tuhan kami, berikanlah kepada kami kebaikan di dunia dan kebaikan di akhirat, serta lindungilah kami dari azab neraka.',
      source: 'QS. Al-Baqarah: 201',
      category: DuaCategory.rezeki,
    ),
    Dua(
      id: 'memohon-ilmu',
      title: 'Doa Memohon Ilmu',
      arabic: 'رَبِّ زِدْنِي عِلْمًا',
      latin: "Rabbi zidni 'ilma.",
      translation: 'Tuhanku, tambahkanlah ilmu kepadaku.',
      source: 'QS. Thaha: 114',
      category: DuaCategory.ilmu,
    ),
    Dua(
      id: 'keresahan',
      title: 'Doa Ketika Gelisah',
      arabic:
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ وَالْعَجْزِ وَالْكَسَلِ وَالْبُخْلِ وَالْجُبْنِ وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
      latin:
          "Allahumma inni a'udzu bika minal hammi wal hazani wal 'ajzi wal kasali wal bukhli wal jubni wa dala'id-daini wa ghalabatir-rijal.",
      translation:
          'Ya Allah, aku berlindung kepada-Mu dari rasa gelisah dan sedih, dari kelemahan dan kemalasan, dari kekikiran dan sifat pengecut, dari beban utang dan tekanan orang lain.',
      source: 'HR. Bukhari no. 6369',
      category: DuaCategory.perlindungan,
      note: 'Dianjurkan dibaca ketika hati sedang gelisah atau menghadapi kesulitan.',
    ),
    Dua(
      id: 'setelah-wudhu',
      title: 'Doa Setelah Wudhu',
      arabic:
          'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
      latin:
          "Asyhadu an la ilaha illallah wa asyhadu anna Muhammadan 'abduhu wa rasuluh.",
      translation:
          'Aku bersaksi bahwa tidak ada tuhan selain Allah, dan aku bersaksi bahwa Muhammad adalah hamba dan rasul-Nya.',
      source: 'HR. Muslim no. 234',
      category: DuaCategory.ibadah,
    ),
    Dua(
      id: 'berbuka-puasa',
      title: 'Doa Setelah Berbuka Puasa',
      arabic:
          'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ',
      latin:
          "Dzahabazh-zhama'u wabtallatil 'uruqu wa tsabatal ajru insya Allah.",
      translation:
          'Telah hilang rasa haus, telah basah urat-urat, dan telah tetap pahala, insya Allah.',
      source: 'HR. Abu Dawud no. 2357 (hasan)',
      category: DuaCategory.ibadah,
      note: 'Dibaca setelah berbuka puasa.',
    ),
    Dua(
      id: 'hujan',
      title: 'Doa Ketika Hujan',
      arabic: 'اللَّهُمَّ صَيِّبًا نَافِعًا',
      latin: "Allahumma shayyiban nafi'a.",
      translation: 'Ya Allah, jadikanlah hujan ini hujan yang bermanfaat.',
      source: 'HR. Bukhari no. 1032',
      category: DuaCategory.harian,
    ),
    Dua(
      id: 'perlindungan',
      title: 'Doa Perlindungan Pagi dan Sore',
      arabic:
          'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      latin:
          "Bismillahilladzi la yadhurru ma'asmihi syai'un fil ardhi wa la fis-sama'i wa huwas-sami'ul 'alim.",
      translation:
          'Dengan nama Allah yang tidak ada sesuatu pun dapat membahayakan bersama nama-Nya, baik di bumi maupun di langit. Dia Maha Mendengar, Maha Mengetahui.',
      source: 'HR. Abu Dawud no. 5088; Tirmidzi no. 3388',
      category: DuaCategory.perlindungan,
      note: 'Dibaca tiga kali pada pagi dan sore hari.',
    ),
    Dua(
      id: 'lapang-dada',
      title: 'Doa Memohon Kelapangan',
      arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
      latin: 'Rabbisyrah li shadri wa yassir li amri.',
      translation: 'Tuhanku, lapangkanlah dadaku dan mudahkanlah urusanku.',
      source: 'QS. Thaha: 25–26',
      category: DuaCategory.ilmu,
    ),
    Dua(
      id: 'masuk-kamar-mandi',
      title: 'Doa Masuk Kamar Mandi',
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
      latin: "Allahumma inni a'udzu bika minal khubutsi wal khaba'its.",
      translation:
          'Ya Allah, aku berlindung kepada-Mu dari setan jantan dan setan betina.',
      source: 'HR. Bukhari no. 142; Muslim no. 375',
      category: DuaCategory.perlindungan,
    ),
    Dua(
      id: 'keluar-kamar-mandi',
      title: 'Doa Keluar Kamar Mandi',
      arabic: 'غُفْرَانَكَ',
      latin: 'Ghufranak.',
      translation: 'Aku memohon ampunan-Mu.',
      source: 'HR. Abu Dawud no. 30; Tirmidzi no. 7',
      category: DuaCategory.perlindungan,
    ),
    Dua(
      id: 'menjenguk-sakit',
      title: 'Doa Menjenguk Orang Sakit',
      arabic:
          'أَسْأَلُ اللَّهَ الْعَظِيمَ رَبَّ الْعَرْشِ الْعَظِيمِ أَنْ يَشْفِيَكَ',
      latin:
          "As'alullaha al-'azhima rabbal 'arsyil 'azhimi an yasyfiyak.",
      translation:
          'Aku memohon kepada Allah Yang Maha Agung, Tuhan pemilik Arsy yang agung, agar Dia menyembuhkanmu.',
      source: 'HR. Abu Dawud no. 3106; Tirmidzi no. 2083',
      category: DuaCategory.kesehatan,
      note: 'Dibaca tujuh kali ketika menjenguk orang sakit.',
    ),
    Dua(
      id: 'keluarga',
      title: 'Doa untuk Keluarga',
      arabic:
          'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
      latin:
          "Rabbana hab lana min azwajina wa dzurriyyatina qurrata a'yunin waj'alna lil-muttaqina imama.",
      translation:
          'Tuhan kami, anugerahkanlah kepada kami pasangan dan keturunan yang menjadi penyejuk mata, dan jadikanlah kami pemimpin bagi orang-orang yang bertakwa.',
      source: 'QS. Al-Furqan: 74',
      category: DuaCategory.keluarga,
    ),
    Dua(
      id: 'rezeki',
      title: 'Doa Memohon Rezeki Halal',
      arabic:
          'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
      latin:
          "Allahummakfini bihalalika 'an haramika wa aghnini bifadhlika 'amman siwak.",
      translation:
          'Ya Allah, cukupkanlah aku dengan yang halal dari-Mu dan jauhkanlah aku dari yang haram, serta kayakanlah aku dengan karunia-Mu dari bergantung kepada selain-Mu.',
      source: 'HR. Tirmidzi no. 3563 (hasan)',
      category: DuaCategory.rezeki,
    ),
    Dua(
      id: 'syukur',
      title: 'Doa Agar Selalu Bersyukur',
      arabic: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
      latin: "Allahumma a'inni 'ala dzikrika wa syukrika wa husni 'ibadatik.",
      translation:
          'Ya Allah, tolonglah aku untuk selalu mengingat-Mu, bersyukur kepada-Mu, dan beribadah kepada-Mu dengan baik.',
      source: "HR. Abu Dawud no. 1522; Nasa'i no. 1303",
      category: DuaCategory.ibadah,
    ),
  ];

  static Dua byId(String id) =>
      all.firstWhere((dua) => dua.id == id, orElse: () => all.first);

  static List<Dua> search(String query, {DuaCategory? category}) {
    final normalized = query.trim().toLowerCase();
    return all.where((dua) {
      final matchesCategory = category == null || dua.category == category;
      if (!matchesCategory) return false;
      if (normalized.isEmpty) return true;
      return dua.title.toLowerCase().contains(normalized) ||
          dua.translation.toLowerCase().contains(normalized) ||
          dua.latin.toLowerCase().contains(normalized) ||
          dua.category.label.toLowerCase().contains(normalized);
    }).toList(growable: false);
  }

  static Dua duaOfTheDay(DateTime date) {
    final dayOfYear = int.parse(
      date.difference(DateTime(date.year, 1, 1)).inDays.toString(),
    );
    return all[dayOfYear % all.length];
  }
}
