enum SpiritualModule {
  examination,
  prayerIntention,
  journal,
}

final class SpiritualEntry {
  const SpiritualEntry({
    required this.id,
    required this.module,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.title,
    this.scheduleJson,
    this.deletedAt,
    this.respondedAt,
    this.isDirty = true,
    this.lastSyncedAt,
  });

  final String id;
  final SpiritualModule module;
  final String? userId;
  final String? title;
  final String body;
  final String? scheduleJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? respondedAt;
  final bool isDirty;
  final DateTime? lastSyncedAt;

  SpiritualEntry copyWith({
    String? id,
    SpiritualModule? module,
    String? userId,
    String? title,
    String? body,
    String? scheduleJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    DateTime? respondedAt,
    bool? isDirty,
    DateTime? lastSyncedAt,
  }) {
    return SpiritualEntry(
      id: id ?? this.id,
      module: module ?? this.module,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduleJson: scheduleJson ?? this.scheduleJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      isDirty: isDirty ?? this.isDirty,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
