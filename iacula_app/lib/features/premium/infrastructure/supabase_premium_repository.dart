import 'package:iacula_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class PremiumRemoteGateway {
  Future<PremiumStatus?> fetchForUser(String userId);
  Future<void> upsertForUser(String userId, PremiumStatus status);
}

final class SupabasePremiumGateway implements PremiumRemoteGateway {
  SupabasePremiumGateway(this._client);

  final SupabaseClient _client;

  void _assertAuthenticatedUser(String userId) {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw StateError(
        'Cannot access premium data without authenticated user.',
      );
    }
    if (currentUserId != userId) {
      throw StateError(
        'UserId mismatch: query targets a different user than the authenticated session.',
      );
    }
  }

  @override
  Future<PremiumStatus?> fetchForUser(String userId) async {
    _assertAuthenticatedUser(userId);
    final rows = await _client
        .from('user_premium')
        .select()
        .eq('id', userId)
        .limit(1);

    final list = rows as List<dynamic>;
    if (list.isEmpty) {
      return null;
    }

    final row = Map<String, dynamic>.from(list.first as Map<dynamic, dynamic>);
    return PremiumStatus(
      isPremium: row['is_premium'] == true,
      purchaseDate: row['purchase_date'] == null
          ? null
          : DateTime.tryParse(row['purchase_date'] as String)?.toUtc(),
      storeTransactionId: row['store_transaction_id'] as String?,
      userId: userId,
    );
  }

  @override
  Future<void> upsertForUser(String userId, PremiumStatus status) async {
    _assertAuthenticatedUser(userId);
    await _client.from('user_premium').upsert(<String, dynamic>{
      'id': userId,
      'is_premium': status.isPremium,
      'purchase_date': status.purchaseDate?.toUtc().toIso8601String(),
      'store_transaction_id': status.storeTransactionId,
    });
  }
}

final class SyncedPremiumRepository implements PremiumRepository {
  SyncedPremiumRepository({
    required PremiumRepository localRepository,
    required AuthRepository authRepository,
    required PremiumRemoteGateway remoteGateway,
  }) : _localRepository = localRepository,
       _authRepository = authRepository,
       _remoteGateway = remoteGateway;

  final PremiumRepository _localRepository;
  final AuthRepository _authRepository;
  final PremiumRemoteGateway _remoteGateway;

  @override
  Future<PremiumStatus> getStatus() async {
    var local = await _localRepository.getStatus();
    final user = await _authRepository.currentUser();
    if (user == null) {
      return local;
    }

    PremiumStatus? remote;
    try {
      remote = await _remoteGateway.fetchForUser(user.id);
    } catch (_) {
      return local;
    }
    if (remote == null) {
      if (local.isPremium) {
        final linkedLocal = local.copyWith(userId: user.id);
        await _localRepository.unlockPremium(linkedLocal);
        try {
          await _remoteGateway.upsertForUser(user.id, linkedLocal);
        } catch (_) {}
        return linkedLocal;
      }
      return local;
    }

    if (remote.isPremium && !local.isPremium) {
      final linkedRemote = remote.copyWith(userId: user.id);
      await _localRepository.unlockPremium(linkedRemote);
      return linkedRemote;
    }

    if (!remote.isPremium && local.isPremium) {
      final linkedLocal = local.copyWith(userId: user.id);
      try {
        await _remoteGateway.upsertForUser(user.id, linkedLocal);
      } catch (_) {}
      await _localRepository.unlockPremium(linkedLocal);
      return linkedLocal;
    }

    if (local.userId != user.id) {
      final linkedLocal = local.copyWith(userId: user.id);
      await _localRepository.unlockPremium(linkedLocal);
      return linkedLocal;
    }

    return local;
  }

  @override
  Future<void> unlockPremium(PremiumStatus status) async {
    await _localRepository.unlockPremium(status);
    final user = await _authRepository.currentUser();
    if (user == null) {
      return;
    }

    final linked = status.copyWith(userId: user.id);
    await _localRepository.unlockPremium(linked);
    try {
      await _remoteGateway.upsertForUser(user.id, linked);
    } catch (_) {}
  }

  @override
  Future<bool> restorePurchases() async {
    await getStatus();
    return (await _localRepository.getStatus()).isPremium;
  }

  @override
  Stream<PremiumStatus> watchStatus() {
    return _localRepository.watchStatus();
  }
}
