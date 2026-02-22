import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/spiritual_data/domain/entities/spiritual_entry.dart';
import 'package:iacula_app/features/sync/infrastructure/repositories/supabase_spiritual_sync_repository.dart';

void main() {
  test(
    'pullChanges requests table with user filter and optional since',
    () async {
      final gateway = _FakeGateway(
        pulledRows: [
          {
            'id': 'a1',
            'user_id': 'user-1',
            'title': 'Rule',
            'body': 'Pray',
            'schedule_json': '{"weekday":1}',
            'created_at': '2026-02-22T10:00:00.000Z',
            'updated_at': '2026-02-22T11:00:00.000Z',
            'deleted_at': null,
            'device_id': 'dev-1',
          },
        ],
      );
      final repo = SupabaseSpiritualSyncRepository(
        module: SpiritualModule.planOfLife,
        table: 'plan_of_life_entries',
        gateway: gateway,
      );

      final result = await repo.pullChanges(
        since: DateTime.utc(2026, 2, 22, 9),
        userId: 'user-1',
      );

      expect(gateway.lastPullTable, 'plan_of_life_entries');
      expect(gateway.lastPullUserId, 'user-1');
      expect(gateway.lastPullSince, DateTime.utc(2026, 2, 22, 9));
      expect(result.single.module, SpiritualModule.planOfLife);
      expect(result.single.scheduleJson, '{"weekday":1}');
    },
  );

  test(
    'pushChanges maps entries to rows and returns server timestamps',
    () async {
      final gateway = _FakeGateway(
        pushedResponseRows: [
          {
            'id': 'a1',
            'user_id': 'user-1',
            'title': null,
            'body': 'Remote canonical body',
            'schedule_json': null,
            'created_at': '2026-02-22T10:00:00.000Z',
            'updated_at': '2026-02-22T12:00:00.000Z',
            'deleted_at': '2026-02-22T12:00:00.000Z',
            'device_id': 'dev-2',
          },
        ],
      );
      final repo = SupabaseSpiritualSyncRepository(
        module: SpiritualModule.examination,
        table: 'examination_entries',
        gateway: gateway,
      );

      final pushed = await repo.pushChanges(
        userId: 'user-1',
        localChanges: [
          SpiritualEntry(
            id: 'a1',
            module: SpiritualModule.examination,
            body: 'Local body',
            createdAt: DateTime.utc(2026, 2, 22, 10),
            updatedAt: DateTime.utc(2026, 2, 22, 11),
            deletedAt: DateTime.utc(2026, 2, 22, 11),
          ),
        ],
      );

      expect(gateway.lastPushTable, 'examination_entries');
      expect(gateway.lastPushUserId, 'user-1');
      expect(gateway.lastPushedRows.single['schedule_json'], isNull);
      expect(pushed.single.updatedAt, DateTime.utc(2026, 2, 22, 12));
      expect(pushed.single.body, 'Remote canonical body');
    },
  );

  test('propagates transient gateway failures', () async {
    final gateway = _FakeGateway(error: TimeoutException('timeout'));
    final repo = SupabaseSpiritualSyncRepository(
      module: SpiritualModule.prayerIntention,
      table: 'prayer_intention_entries',
      gateway: gateway,
    );

    expect(
      () => repo.pullChanges(since: null, userId: 'user-1'),
      throwsA(isA<TimeoutException>()),
    );
  });
}

final class _FakeGateway implements SpiritualSyncGateway {
  _FakeGateway({
    this.pulledRows = const <Map<String, dynamic>>[],
    this.pushedResponseRows = const <Map<String, dynamic>>[],
    this.error,
  });

  final List<Map<String, dynamic>> pulledRows;
  final List<Map<String, dynamic>> pushedResponseRows;
  final Object? error;

  String? lastPullTable;
  String? lastPullUserId;
  DateTime? lastPullSince;

  String? lastPushTable;
  String? lastPushUserId;
  List<Map<String, dynamic>> lastPushedRows = const [];

  @override
  Future<List<Map<String, dynamic>>> fetchChangedRows({
    required String table,
    required String userId,
    required DateTime? since,
  }) async {
    if (error != null) throw error!;
    lastPullTable = table;
    lastPullUserId = userId;
    lastPullSince = since;
    return pulledRows;
  }

  @override
  Future<List<Map<String, dynamic>>> upsertRows({
    required String table,
    required String userId,
    required List<Map<String, dynamic>> rows,
  }) async {
    if (error != null) throw error!;
    lastPushTable = table;
    lastPushUserId = userId;
    lastPushedRows = rows;
    return pushedResponseRows;
  }
}
