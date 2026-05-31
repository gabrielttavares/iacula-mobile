import '../entities/custom_phrase.dart';

/// Pure, deterministic decisions for the guaranteed 1-in-4 personal-phrase
/// feed share.
///
/// The app fills feed slots (hero card and scheduled notifications) mostly with
/// liturgical quotes, but reserves roughly every 4th slot for an eligible
/// personal phrase. This service owns those decisions in isolation: no I/O, no
/// Riverpod, no clock reads beyond the [DateTime] arguments callers pass in.
/// Every method is a pure function of its inputs, so it is fully unit-testable.
final class PersonalPhraseFeedSelector {
  const PersonalPhraseFeedSelector._();

  /// One personal slot for every [shareStride] feed slots (a 1-in-4 share).
  static const int shareStride = 4;

  /// Whether the slot at [slotIndex] is reserved for a personal phrase.
  ///
  /// The last slot of each stride window is personal, so indices 3, 7, 11 are
  /// personal while 0, 1, 2 are not.
  static bool isPersonalSlot(int slotIndex) =>
      slotIndex % shareStride == shareStride - 1;

  /// Personal phrases that may fill a hero feed slot: active, opted in to the
  /// hero card, and rotating (fixed-schedule phrases own their own slots).
  static List<CustomPhrase> eligibleForHero(List<CustomPhrase> phrases) =>
      phrases
          .where((phrase) =>
              phrase.isActive && phrase.displayOnHero && phrase.isRotationMode)
          .toList();

  /// Personal phrases that may fill a notification feed slot: active, opted in
  /// to notifications, and rotating.
  static List<CustomPhrase> eligibleForNotifications(
    List<CustomPhrase> phrases,
  ) =>
      phrases
          .where((phrase) =>
              phrase.isActive &&
              phrase.displayAsNotification &&
              phrase.isRotationMode)
          .toList();

  /// The personal phrase that fills the slot at [slotIndex], or null when the
  /// slot is not personal or [eligible] is empty.
  ///
  /// Picks by personal-slot ordinal (how many personal slots precede this one)
  /// modulo the pool size, so the pool cycles in stable order across slots.
  static CustomPhrase? phraseForSlot({
    required int slotIndex,
    required List<CustomPhrase> eligible,
  }) {
    if (eligible.isEmpty || !isPersonalSlot(slotIndex)) return null;
    final personalOrdinal = slotIndex ~/ shareStride;
    return eligible[personalOrdinal % eligible.length];
  }

  /// Width of each fire-time bucket, in minutes. Fire times within the same
  /// bucket map to the same slot index.
  static const int _bucketMinutes = 15;

  /// A stable slot index derived from a fire time's clock position in the day.
  ///
  /// Buckets the time-of-day into [_bucketMinutes] windows so that a given
  /// notification time always lands on the same slot, keeping the personal
  /// share decision stable across reschedules.
  static int slotIndexForFireTime(DateTime fireAt) {
    final minutesOfDay = fireAt.hour * 60 + fireAt.minute;
    return minutesOfDay ~/ _bucketMinutes;
  }
}
