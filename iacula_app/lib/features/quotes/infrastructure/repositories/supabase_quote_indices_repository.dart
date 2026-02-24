import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/quote_indices.dart';
import '../../domain/repositories/quote_indices_repository.dart';

abstract interface class QuoteIndicesRemoteGateway {
  Future<QuoteIndices?> fetchForUser(String userId);
  Future<void> upsertForUser(String userId, QuoteIndices indices);
}

final class SupabaseQuoteIndicesGateway implements QuoteIndicesRemoteGateway {
  SupabaseQuoteIndicesGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<QuoteIndices?> fetchForUser(String userId) async {
    final rows = await _client
        .from('user_quote_state')
        .select()
        .eq('user_id', userId)
        .limit(1);

    final list = rows as List<dynamic>;
    if (list.isEmpty) {
      return null;
    }

    final row = Map<String, dynamic>.from(list.first as Map<dynamic, dynamic>);
    return QuoteIndices(
      quoteIndices: _parseIntMap(row['quote_indices_json']),
      imageIndices: _parseIntMap(row['image_indices_json']),
      lastDay: row['last_day'] as int,
    );
  }

  @override
  Future<void> upsertForUser(String userId, QuoteIndices indices) async {
    await _client.from('user_quote_state').upsert(<String, dynamic>{
      'user_id': userId,
      'last_day': indices.lastDay,
      'quote_indices_json': _toJsonMap(indices.quoteIndices),
      'image_indices_json': _toJsonMap(indices.imageIndices),
    });
  }

  Map<int, int> _parseIntMap(dynamic value) {
    if (value is! Map) {
      return const <int, int>{};
    }

    final parsed = <int, int>{};
    value.forEach((key, raw) {
      final parsedKey = int.tryParse(key.toString());
      if (parsedKey == null || raw is! num) {
        return;
      }
      parsed[parsedKey] = raw.toInt();
    });
    return parsed;
  }

  Map<String, int> _toJsonMap(Map<int, int> source) {
    final mapped = <String, int>{};
    source.forEach((key, value) {
      mapped['$key'] = value;
    });
    return mapped;
  }
}

final class SyncedQuoteIndicesRepository implements QuoteIndicesRepository {
  SyncedQuoteIndicesRepository({
    required QuoteIndicesRepository localRepository,
    required AuthRepository authRepository,
    required QuoteIndicesRemoteGateway remoteGateway,
  }) : _localRepository = localRepository,
       _authRepository = authRepository,
       _remoteGateway = remoteGateway;

  final QuoteIndicesRepository _localRepository;
  final AuthRepository _authRepository;
  final QuoteIndicesRemoteGateway _remoteGateway;

  @override
  Future<QuoteIndices> load({required int dayOfWeek}) async {
    final local = await _localRepository.load(dayOfWeek: dayOfWeek);
    final user = await _authRepository.currentUser();
    if (user == null) {
      return local;
    }

    QuoteIndices? remote;
    try {
      remote = await _remoteGateway.fetchForUser(user.id);
    } catch (_) {
      return local;
    }

    if (remote == null) {
      try {
        await _remoteGateway.upsertForUser(user.id, local);
      } catch (_) {}
      return local;
    }

    final localEmpty =
        local.quoteIndices.isEmpty && local.imageIndices.isEmpty;
    final remoteHasData =
        remote.quoteIndices.isNotEmpty || remote.imageIndices.isNotEmpty;
    if (localEmpty && remoteHasData) {
      await _localRepository.save(remote);
      return remote;
    }

    if (!_same(local, remote)) {
      try {
        await _remoteGateway.upsertForUser(user.id, local);
      } catch (_) {}
    }

    return local;
  }

  @override
  Future<void> save(QuoteIndices indices) async {
    await _localRepository.save(indices);
    final user = await _authRepository.currentUser();
    if (user == null) {
      return;
    }
    try {
      await _remoteGateway.upsertForUser(user.id, indices);
    } catch (_) {}
  }

  bool _same(QuoteIndices a, QuoteIndices b) {
    return a.lastDay == b.lastDay &&
        _sameMap(a.quoteIndices, b.quoteIndices) &&
        _sameMap(a.imageIndices, b.imageIndices);
  }

  bool _sameMap(Map<int, int> a, Map<int, int> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}
