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
}
