import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Registers the app's bundled Lora and Inter weights with the test font engine
/// so golden tests render real glyphs deterministically.
///
/// google_fonts disables runtime fetching in tests (see flutter_test_config.dart)
/// and resolves bundled fonts through the asset manifest. The manifest is not
/// reliably regenerated for `flutter test` when font files are added, so we load
/// the ttf bytes straight from disk and register them under the exact family
/// strings google_fonts assigns (`<family>_<variant>`, e.g. `Inter_regular`,
/// `Inter_600`). Widgets built with `GoogleFonts.inter(...)` request those
/// families, so the engine resolves them even though google_fonts' own asset
/// lookup may miss.
Future<void> loadBundledFontsForGolden() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const fontDir = 'assets/fonts/google_fonts';
  // Family string (as google_fonts names it) -> bundled ttf file.
  const familyToFile = <String, String>{
    'Lora_regular': 'Lora-Regular.ttf',
    'Lora_500': 'Lora-Medium.ttf',
    'Lora_600': 'Lora-SemiBold.ttf',
    'Lora_700': 'Lora-Bold.ttf',
    'Inter_regular': 'Inter-Regular.ttf',
    'Inter_500': 'Inter-Medium.ttf',
    'Inter_600': 'Inter-SemiBold.ttf',
  };

  for (final entry in familyToFile.entries) {
    final bytes = await File('$fontDir/${entry.value}').readAsBytes();
    final loader = FontLoader(entry.key)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }
}
