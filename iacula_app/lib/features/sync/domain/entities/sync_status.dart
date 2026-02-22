enum SyncPhase { idle, syncing, error }

final class SyncStatus {
  const SyncStatus({
    required this.phase,
    this.lastSyncedAt,
    this.message,
  });

  final SyncPhase phase;
  final DateTime? lastSyncedAt;
  final String? message;

  static const idle = SyncStatus(phase: SyncPhase.idle);

  SyncStatus copyWith({
    SyncPhase? phase,
    DateTime? lastSyncedAt,
    String? message,
  }) {
    return SyncStatus(
      phase: phase ?? this.phase,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      message: message ?? this.message,
    );
  }
}
