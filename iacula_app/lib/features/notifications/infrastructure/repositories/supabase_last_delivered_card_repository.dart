import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/last_delivered_card.dart';
import '../../domain/repositories/last_delivered_card_repository.dart';

abstract interface class LastDeliveredCardRemoteGateway {
  Future<LastDeliveredCard?> fetchForUser(String userId);
  Future<void> upsertForUser(String userId, LastDeliveredCard card);
}

final class SupabaseLastDeliveredCardGateway
    implements LastDeliveredCardRemoteGateway {
  SupabaseLastDeliveredCardGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<LastDeliveredCard?> fetchForUser(String userId) async {
    final rows = await _client
        .from('user_last_delivered_card')
        .select()
        .eq('user_id', userId)
        .limit(1);

    final list = rows as List<dynamic>;
    if (list.isEmpty) {
      return null;
    }

    final row = Map<String, dynamic>.from(list.first as Map<dynamic, dynamic>);
    return LastDeliveredCard(
      quoteText: row['quote_text'] as String,
      theme: row['theme'] as String,
      season: row['season'] as String,
      deliveredAt: DateTime.parse(row['delivered_at'] as String).toUtc(),
      imagePath: row['image_path'] as String?,
      feast: row['feast'] as String?,
      feastName: row['feast_name'] as String?,
    );
  }

  @override
  Future<void> upsertForUser(String userId, LastDeliveredCard card) async {
    await _client.from('user_last_delivered_card').upsert(<String, dynamic>{
      'user_id': userId,
      'quote_text': card.quoteText,
      'theme': card.theme,
      'season': card.season,
      'image_path': card.imagePath,
      'feast': card.feast,
      'feast_name': card.feastName,
      'delivered_at': card.deliveredAt.toUtc().toIso8601String(),
    });
  }
}

final class SyncedLastDeliveredCardRepository
    implements LastDeliveredCardRepository {
  SyncedLastDeliveredCardRepository({
    required LastDeliveredCardRepository localRepository,
    required AuthRepository authRepository,
    required LastDeliveredCardRemoteGateway remoteGateway,
  }) : _localRepository = localRepository,
       _authRepository = authRepository,
       _remoteGateway = remoteGateway;

  final LastDeliveredCardRepository _localRepository;
  final AuthRepository _authRepository;
  final LastDeliveredCardRemoteGateway _remoteGateway;

  @override
  Future<LastDeliveredCard?> load() async {
    final local = await _localRepository.load();
    final user = await _authRepository.currentUser();
    if (user == null) {
      return local;
    }

    LastDeliveredCard? remote;
    try {
      remote = await _remoteGateway.fetchForUser(user.id);
    } catch (_) {
      return local;
    }

    if (remote == null) {
      if (local != null) {
        try {
          await _remoteGateway.upsertForUser(user.id, local);
        } catch (_) {}
      }
      return local;
    }

    if (local == null) {
      await _localRepository.save(remote);
      return remote;
    }

    if (local.deliveredAt.isBefore(remote.deliveredAt)) {
      await _localRepository.save(remote);
      return remote;
    }

    try {
      await _remoteGateway.upsertForUser(user.id, local);
    } catch (_) {}
    return local;
  }

  @override
  Future<void> save(LastDeliveredCard card) async {
    await _localRepository.save(card);
    final user = await _authRepository.currentUser();
    if (user == null) {
      return;
    }
    try {
      await _remoteGateway.upsertForUser(user.id, card);
    } catch (_) {}
  }
}
