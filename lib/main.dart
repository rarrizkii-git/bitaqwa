import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/app_providers.dart';
import 'core/services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Phase 2C: the app's font variants ship in assets/fonts/, so never fall
  // back to fetching them from fonts.gstatic.com at runtime.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Clean URLs on the web: /quran/36 instead of /#/quran/36.
  usePathUrlStrategy();

  Intl.defaultLocale = 'id_ID';
  await initializeDateFormatting('id_ID');

  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(preferences)),
      ],
      child: const BitaqwaApp(),
    ),
  );
}
