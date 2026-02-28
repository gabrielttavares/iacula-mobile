import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../spiritual_data/domain/entities/spiritual_entry.dart';
import '../../domain/repositories/sync_repository.dart';

abstract interface class SpiritualSyncGateway {
  Future<List<Map<String, dynamic>>> fetchChangedRows({
    required String table,
    required String userId,
    required DateTime? since,
  });

  Future<List<Map<String, dynamic>>> upsertRows({
    required String table,
    required String userId,
    required List<Map<String, dynamic>> rows,
  });
}

final class SupabaseSpiritualSyncGateway implements SpiritualSyncGateway {
  SupabaseSpiritualSyncGateway(this._client);

  final SupabaseClient _client;

  void _assertAuthenticatedUser(String userId) {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw StateError('Cannot perform sync operation without authenticated user.');
    }
    if (currentUserId != userId) {
      throw StateError(
        'UserId mismatch: query targets a different user than the authenticated session.',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchChangedRows({
    required String table,
    required String userId,
    required DateTime? since,
  }) async {
    _assertAuthenticatedUser(userId);
    dynamic query = _client.from(table).select().eq('user_id', userId);
    if (since != null) {
      query = query.gt('updated_at', since.toUtc().toIso8601String());
    }

    final rows = await query.order('updated_at');
    return _castRows(rows);
  }

  @override
  Future<List<Map<String, dynamic>>> upsertRows({
    required String table,
    required String userId,
    required List<Map<String, dynamic>> rows,
  }) async {
    _assertAuthenticatedUser(userId);
    if (rows.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    final payload = rows
        .map((row) {
          final copy = Map<String, dynamic>.from(row);
          copy['user_id'] = userId;
          return copy;
        })
        .toList(growable: false);

    final result = await _client
        .from(table)
        .upsert(payload, onConflict: 'id')
        .select();
    return _castRows(result);
  }

  List<Map<String, dynamic>> _castRows(dynamic rows) {
    final list = rows as List<dynamic>;
    return list
        .map((item) => Map<String, dynamic>.from(item as Map<dynamic, dynamic>))
        .toList(growable: false);
  }
}

final class SupabaseSpiritualSyncRepository implements SyncRepository {
  SupabaseSpiritualSyncRepository({
    required this.module,
    required this.table,
    required SpiritualSyncGateway gateway,
    int maxRetries = 2,
    Future<void> Function(Duration delay)? retryDelay,
  }) : _gateway = gateway,
       _maxRetries = maxRetries,
       _retryDelay = retryDelay ?? Future<void>.delayed;

  @override
  final SpiritualModule module;

  final String table;
  final SpiritualSyncGateway _gateway;
  final int _maxRetries;
  final Future<void> Function(Duration delay) _retryDelay;

  @override
  Future<List<SpiritualEntry>> pullChanges({
    required DateTime? since,
    required String userId,
  }) async {
    final rows = await _withRetry(
      () =>
          _gateway.fetchChangedRows(table: table, userId: userId, since: since),
    );
    return rows
        .map((row) => _fromRow(row, module: module))
        .toList(growable: false);
  }

  @override
  Future<List<SpiritualEntry>> pushChanges({
    required List<SpiritualEntry> localChanges,
    required String userId,
  }) async {
    final rows = localChanges
        .map((entry) => _toRow(entry, userId: userId))
        .toList(growable: false);
    final responseRows = await _withRetry(
      () => _gateway.upsertRows(table: table, userId: userId, rows: rows),
    );
    return responseRows
        .map((row) => _fromRow(row, module: module))
        .toList(growable: false);
  }

  Future<T> _withRetry<T>(Future<T> Function() op) async {
    var attempt = 0;
    while (true) {
      try {
        return await op();
      } catch (error) {
        if (!_isTransient(error) || attempt >= _maxRetries) {
          rethrow;
        }

        attempt += 1;
        final delayMs = 200 * attempt;
        await _retryDelay(Duration(milliseconds: delayMs));
      }
    }
  }

  bool _isTransient(Object error) {
    return error is TimeoutException || error is SocketException;
  }

  static SpiritualEntry _fromRow(
    Map<String, dynamic> row, {
    required SpiritualModule module,
  }) {
    final schedule = module == SpiritualModule.planOfLife
        ? row['schedule_json'] as String?
        : null;

    return SpiritualEntry(
      id: row['id'] as String,
      module: module,
      userId: row['user_id'] as String?,
      title: row['title'] as String?,
      body: row['body'] as String,
      scheduleJson: schedule,
      createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(row['updated_at'] as String).toUtc(),
      deletedAt: row['deleted_at'] == null
          ? null
          : DateTime.parse(row['deleted_at'] as String).toUtc(),
      isDirty: false,
    );
  }

  static Map<String, dynamic> _toRow(
    SpiritualEntry entry, {
    required String userId,
  }) {
    final schedule = entry.module == SpiritualModule.planOfLife
        ? entry.scheduleJson
        : null;

    return <String, dynamic>{
      'id': entry.id,
      'user_id': userId,
      'title': entry.title,
      'body': entry.body,
      'schedule_json': schedule,
      'created_at': entry.createdAt.toUtc().toIso8601String(),
      'updated_at': entry.updatedAt.toUtc().toIso8601String(),
      'deleted_at': entry.deletedAt?.toUtc().toIso8601String(),
      'device_id': null,
    };
  }
}
