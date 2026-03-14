import 'package:shared_preferences/shared_preferences.dart';

/// Provides data for native home screen widgets by writing to SharedPreferences
/// (Android) / UserDefaults (iOS) via the home_widget package pattern.
///
/// Native widgets read this data to render content without launching the app.
final class WidgetDataProvider {
  static const _prefix = 'widget_';

  /// Updates widget data that native home screen widgets can read.
  Future<void> updateWidgetData({
    required String dailyReflection,
    required String liturgicalColor,
    required int streakCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      '${_prefix}daily_reflection',
      dailyReflection,
    );
    await prefs.setString(
      '${_prefix}liturgical_color',
      liturgicalColor,
    );
    await prefs.setInt(
      '${_prefix}streak_count',
      streakCount,
    );
    await prefs.setString(
      '${_prefix}last_updated',
      DateTime.now().toIso8601String(),
    );
  }

  /// Reads current widget data (for debugging/verification).
  Future<Map<String, dynamic>> readWidgetData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'dailyReflection': prefs.getString('${_prefix}daily_reflection'),
      'liturgicalColor': prefs.getString('${_prefix}liturgical_color'),
      'streakCount': prefs.getInt('${_prefix}streak_count'),
      'lastUpdated': prefs.getString('${_prefix}last_updated'),
    };
  }
}
