import '../models/dhikr.dart';

abstract final class DhikrPresets {
  static const all = <DhikrPreset>[
    DhikrPreset(
      id: 'subhanallah',
      title: 'Subhanallah',
      arabic: 'سُبْحَانَ اللَّهِ',
      latin: 'Subhanallah',
      translation: 'Maha Suci Allah.',
      reference: 'HR. Bukhari no. 843; Muslim no. 597',
      defaultTarget: 33,
      note: 'Dibaca 33 kali setelah shalat fardhu.',
    ),
    DhikrPreset(
      id: 'alhamdulillah',
      title: 'Alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      latin: 'Alhamdulillah',
      translation: 'Segala puji bagi Allah.',
      reference: 'HR. Bukhari no. 843; Muslim no. 597',
      defaultTarget: 33,
      note: 'Dibaca 33 kali setelah shalat fardhu.',
    ),
    DhikrPreset(
      id: 'allahuakbar',
      title: 'Allahu Akbar',
      arabic: 'اللَّهُ أَكْبَرُ',
      latin: 'Allahu Akbar',
      translation: 'Allah Maha Besar.',
      reference: 'HR. Bukhari no. 843; Muslim no. 597',
      defaultTarget: 34,
      note: 'Dibaca 34 kali setelah shalat fardhu.',
    ),
    DhikrPreset(
      id: 'tahlil',
      title: 'Tahlil',
      arabic:
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      latin:
          'La ilaha illallahu wahdahu la syarika lahu, lahul mulku wa lahul hamdu wa huwa ala kulli syai-in qadir.',
      translation:
          'Tidak ada tuhan selain Allah, Yang Maha Esa, tidak ada sekutu bagi-Nya. Bagi-Nya kerajaan dan segala pujian, dan Dia Maha Kuasa atas segala sesuatu.',
      reference: 'HR. Bukhari no. 3293; Muslim no. 2691',
      defaultTarget: 100,
      note: 'Dibaca 100 kali dalam sehari.',
    ),
    DhikrPreset(
      id: 'istighfar',
      title: 'Istighfar',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      latin: 'Astaghfirullah',
      translation: 'Aku memohon ampun kepada Allah.',
      reference: 'HR. Muslim no. 2702',
      defaultTarget: 100,
      note: 'Rasulullah ﷺ beristighfar lebih dari 100 kali dalam sehari.',
    ),
    DhikrPreset(
      id: 'hauqalah',
      title: 'Hauqalah',
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      latin: 'La hawla wa la quwwata illa billah',
      translation: 'Tidak ada daya dan kekuatan kecuali dengan Allah.',
      reference: 'HR. Bukhari no. 6384',
      defaultTarget: 100,
      note: 'Termasuk kalimat yang disebut sebagai simpanan di surga.',
    ),
    DhikrPreset(
      id: 'shalawat',
      title: 'Shalawat',
      arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
      latin: "Allahumma shalli 'ala Muhammad",
      translation: 'Ya Allah, limpahkanlah shalawat kepada Nabi Muhammad.',
      reference: 'HR. Muslim no. 408',
      defaultTarget: 100,
      note:
          'Barang siapa bershalawat sekali, Allah akan bershalawat kepadanya sepuluh kali.',
    ),
    DhikrPreset(
      id: 'hasbunallah',
      title: 'Hasbunallah',
      arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      latin: "Hasbunallahu wa ni'mal wakil",
      translation: 'Cukuplah Allah bagi kami, dan Dia sebaik-baik pelindung.',
      reference: 'QS. Ali Imran: 173',
      defaultTarget: 100,
      note: 'Dianjurkan diperbanyak ketika menghadapi kesulitan.',
    ),
    DhikrPreset(
      id: 'subhanallah-bihamdihi',
      title: 'Subhanallahi wa Bihamdihi',
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      latin: 'Subhanallahi wa bihamdihi',
      translation: 'Maha Suci Allah dan segala puji bagi-Nya.',
      reference: 'HR. Bukhari no. 6405; Muslim no. 2691',
      defaultTarget: 100,
      note:
          'Dibaca 100 kali; dosa-dosa akan diampuni walaupun sebanyak buih di lautan.',
    ),
  ];

  static DhikrPreset byId(String id) => all.firstWhere(
        (preset) => preset.id == id,
        orElse: () => all.first,
      );
}
