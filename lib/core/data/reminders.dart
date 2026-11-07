import 'package:flutter/foundation.dart';

@immutable
class Reminder {
  const Reminder({
    required this.id,
    required this.arabic,
    required this.translation,
    required this.reference,
  });

  final String id;
  final String arabic;
  final String translation;
  final String reference;
}

abstract final class Reminders {
  static const all = <Reminder>[
    Reminder(
      id: 'insyirah',
      arabic: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      translation:
          'Maka sesungguhnya bersama kesulitan ada kemudahan. Sesungguhnya bersama kesulitan ada kemudahan.',
      reference: 'QS. Al-Insyirah: 5–6',
    ),
    Reminder(
      id: 'rad',
      arabic: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      translation:
          'Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram.',
      reference: "QS. Ar-Ra'd: 28",
    ),
    Reminder(
      id: 'talaq',
      arabic: 'وَمَنْ يَتَّقِ اللَّهَ يَجْعَلْ لَهُ مَخْرَجًا',
      translation:
          'Dan barangsiapa bertakwa kepada Allah, niscaya Dia akan mengadakan jalan keluar baginya.',
      reference: 'QS. At-Talaq: 2',
    ),
    Reminder(
      id: 'baqarah',
      arabic: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ',
      translation:
          'Dan apabila hamba-hamba-Ku bertanya kepadamu tentang Aku, maka sesungguhnya Aku dekat.',
      reference: 'QS. Al-Baqarah: 186',
    ),
    Reminder(
      id: 'ibrahim',
      arabic: 'لَئِنْ شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
      translation:
          'Sesungguhnya jika kamu bersyukur, pasti Kami akan menambah nikmat kepadamu.',
      reference: 'QS. Ibrahim: 7',
    ),
  ];
}
