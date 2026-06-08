import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Preloads every font the app renders (Lora serif for titles/prayer text,
/// Inter sans for UI/secondary text) when the device is online, so they are
/// cached and available offline on subsequent launches. The ttf files are also
/// bundled under assets/fonts/google_fonts/, so google_fonts resolves them
/// locally even on a first launch with no network.
Future<void> loadAppFontsWhenOnline(Connectivity connectivity) async {
  final results = await connectivity.checkConnectivity();
  final hasConnection = results.any((r) => r != ConnectivityResult.none);
  if (!hasConnection) return;

  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.lora(fontWeight: FontWeight.w400),
      GoogleFonts.lora(fontWeight: FontWeight.w500),
      GoogleFonts.lora(fontWeight: FontWeight.w600),
      GoogleFonts.lora(fontWeight: FontWeight.w700),
      GoogleFonts.inter(fontWeight: FontWeight.w400),
      GoogleFonts.inter(fontWeight: FontWeight.w500),
      GoogleFonts.inter(fontWeight: FontWeight.w600),
    ]);
  } catch (_) {
    // Ignore: next run with network will retry, or first text render triggers
    // the bundled-asset load.
  }
}
