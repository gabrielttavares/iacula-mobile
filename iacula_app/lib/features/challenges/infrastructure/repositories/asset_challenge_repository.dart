import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/challenge.dart';
import '../../domain/repositories/challenge_repository.dart';

final class AssetChallengeRepository implements ChallengeRepository {
  List<Challenge>? _cache;

  @override
  Future<List<Challenge>> listAll() async {
    if (_cache != null) return _cache!;

    final raw =
        await rootBundle.loadString('assets/seed/challenges/challenges.json');
    final List<dynamic> decoded = jsonDecode(raw) as List;
    _cache = decoded
        .map((e) => Challenge.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  @override
  Future<Challenge?> getById(String id) async {
    final all = await listAll();
    return all.where((c) => c.id == id).firstOrNull;
  }
}
