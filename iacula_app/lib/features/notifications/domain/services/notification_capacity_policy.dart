/// How much of the chosen quote cadence the platform can pre-schedule, and how
/// far it reaches while the app stays closed.
///
/// iOS holds at most 64 pending local notifications app-wide, so a tight cadence
/// cannot be honored closed-app — the budget is spread thin across the runway.
/// Android has no such cap and fires exact alarms while idle, so the chosen
/// cadence runs at full density for a few days and then steps down to a gentler
/// tail (rather than stopping) until the app is reopened.
///
/// This is a pure value object. The platform is resolved once at the
/// composition root and the matching policy is injected, so the scheduling
/// domain never reads `Platform` directly and stays deterministic under test.
final class NotificationCapacityPolicy {
  const NotificationCapacityPolicy({
    required this.pendingTotalCapacity,
    required this.pendingQuoteCapacity,
    required this.denseRunwayDays,
    required this.spreadAcrossRunway,
    required this.tailCadenceDivisor,
    required this.tailHorizonDays,
  });

  /// iOS: the shared 64-pending cap is the real OS limit. Quotes spread across
  /// the runway so a never-opened app keeps a pulse for a week. No tail (the cap
  /// is the ceiling), so [tailCadenceDivisor] is 1 and [tailHorizonDays] equals
  /// the dense runway.
  static const NotificationCapacityPolicy ios = NotificationCapacityPolicy(
    pendingTotalCapacity: 64,
    pendingQuoteCapacity: 64,
    denseRunwayDays: 7,
    spreadAcrossRunway: true,
    tailCadenceDivisor: 1,
    tailHorizonDays: 7,
  );

  /// Android: no pending cap, exact alarms fire while idle. Honor the chosen
  /// cadence at full density for [denseRunwayDays], then continue at half
  /// cadence out to [tailHorizonDays] so a long-closed app still delivers
  /// (gentler) rather than going silent. Re-armed on each app open.
  static const NotificationCapacityPolicy android = NotificationCapacityPolicy(
    pendingTotalCapacity: 2000,
    pendingQuoteCapacity: 2000,
    denseRunwayDays: 3,
    spreadAcrossRunway: false,
    tailCadenceDivisor: 2,
    tailHorizonDays: 14,
  );

  /// The OS ceiling on total pending notifications across every tier. iOS holds
  /// at most 64; Android has no real limit, so this is a sane high ceiling. The
  /// sacred-tier budget (season transitions, liturgy, intentions, phrases) is
  /// bounded by this, not by the iOS number, so Android never drops a promised
  /// reminder against a cap that doesn't exist there.
  final int pendingTotalCapacity;

  /// Upper bound on quote notifications that may be pending at once. On iOS this
  /// shares the [pendingTotalCapacity] cap with every other tier; on Android it
  /// is a sane ceiling well above what any cadence needs.
  final int pendingQuoteCapacity;

  /// Number of leading days delivered at the full chosen cadence.
  final int denseRunwayDays;

  /// When true (iOS), the per-day quote count is the pending budget divided
  /// across the runway, so the cadence is thinned to fit the cap. When false
  /// (Android), each day delivers the full cadence the window allows.
  final bool spreadAcrossRunway;

  /// Divisor applied to the cadence for the post-dense tail. 1 means no tail
  /// (iOS). 2 means half cadence (Android: a 10-min cadence becomes 20-min).
  final int tailCadenceDivisor;

  /// Last day (from today) the tail keeps scheduling. Equals [denseRunwayDays]
  /// when there is no tail.
  final int tailHorizonDays;

  /// Whether this policy adds a reduced-cadence tail after the dense runway.
  bool get hasTail =>
      tailCadenceDivisor > 1 && tailHorizonDays > denseRunwayDays;

  /// The tail cadence (minutes) for a given dense [cadenceMinutes].
  int tailCadenceMinutes(int cadenceMinutes) =>
      cadenceMinutes * tailCadenceDivisor;
}
