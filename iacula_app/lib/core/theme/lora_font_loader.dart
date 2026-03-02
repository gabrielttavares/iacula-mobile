import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Preloads Lora font variants when the device is online so they are cached
/// and available offline on subsequent launches.
Future<void> loadLoraFontsWhenOnline(Connectivity connectivity) async {
  final results = await connectivity.checkConnectivity();
  final hasConnection = results.any((r) => r != ConnectivityResult.none);
  if (!hasConnection) return;

  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.lora(fontWeight: FontWeight.w400),
      GoogleFonts.lora(fontWeight: FontWeight.w500),
      GoogleFonts.lora(fontWeight: FontWeight.w600),
      GoogleFonts.lora(fontWeight: FontWeight.w700),
    ]);
  } catch (_) {
    // Ignore: next run with network will retry or first text render will trigger load.
  }
}
