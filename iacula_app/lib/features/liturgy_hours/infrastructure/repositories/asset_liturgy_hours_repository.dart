import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/liturgical_hour.dart';
import '../../domain/services/psalter_calendar.dart';

final class AssetLiturgyHoursRepository {
  List<LiturgicalHour>? _cache;

  Future<List<LiturgicalHour>> listAll() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle
        .loadString('assets/seed/liturgy_hours/hours.json');
    final List<dynamic> decoded = jsonDecode(raw) as List;
    _cache = decoded
        .map((e) => LiturgicalHour.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<LiturgicalHour?> getHour({
    required LiturgicalHourType type,
    required DateTime date,
  }) async {
    final all = await listAll();
    final calendar = const PsalterCalendar();
    final week = calendar.psalterWeek(date);
    final day = date.weekday;

    return all
        .where((h) => h.type == type && h.psalterWeek == week && h.dayOfWeek == day)
        .firstOrNull ??
        all
        .where((h) => h.type == type && h.psalterWeek == week)
        .firstOrNull ??
        all
        .where((h) => h.type == type)
        .firstOrNull;
  }

  Future<List<LiturgicalHour>> getHoursForDay(DateTime date) async {
    final all = await listAll();
    final calendar = const PsalterCalendar();
    final week = calendar.psalterWeek(date);
    final day = date.weekday;

    return all
        .where((h) => h.psalterWeek == week && h.dayOfWeek == day)
        .toList();
  }
}
