/// Whether quote cadence at short intervals (<= 15 min) can be guaranteed on this device.
final class ShortIntervalReliability {
  const ShortIntervalReliability({required this.guaranteed});

  final bool guaranteed;

  static const ok = ShortIntervalReliability(guaranteed: true);

  /// Android: exact alarms still unavailable after [requestExactAlarmsPermission]; cadence may drift.
  static const exactAlarmsUnavailable = ShortIntervalReliability(guaranteed: false);
}
