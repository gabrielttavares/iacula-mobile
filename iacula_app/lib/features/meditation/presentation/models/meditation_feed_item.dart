import '../../../journal_prompts/domain/entities/journal_prompt.dart';
import '../../domain/entities/meditation_item.dart';

sealed class MeditationFeedItem {
  const MeditationFeedItem();
}

final class MeditationContentFeedItem extends MeditationFeedItem {
  const MeditationContentFeedItem(this.item);

  final MeditationItem item;
}

final class JournalPromptFeedItem extends MeditationFeedItem {
  const JournalPromptFeedItem(this.prompt);

  final JournalPrompt prompt;
}
