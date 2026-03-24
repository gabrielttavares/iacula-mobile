/// Outcome of [RebuildNotificationsUseCase.call].
final class NotificationRebuildResult {
  const NotificationRebuildResult({
    required this.shortIntervalReliabilityNotGuaranteed,
  });

  /// True when interval <= 15 min and the OS does not grant exact alarms after the request flow.
  final bool shortIntervalReliabilityNotGuaranteed;
}
