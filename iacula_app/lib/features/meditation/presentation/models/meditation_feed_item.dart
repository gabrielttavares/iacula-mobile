import '../../../journal_prompts/domain/entities/journal_prompt.dart';
import '../../domain/entities/meditation_item.dart';

sealed class MeditationFeedItem {
  const MeditationFeedItem();
}

final class MeditationContentFeedItem extends MeditationFeedItem {
  const MeditationContentFeedItem(this.item);

  final MeditationItem item;
}

final class JournalPromptGroupFeedItem extends MeditationFeedItem {
  const JournalPromptGroupFeedItem(this.sections);

  final List<JournalPromptSection> sections;
}

final class JournalPromptSection {
  const JournalPromptSection({required this.category, required this.prompts});

  final JournalPromptCategory category;
  final List<JournalPrompt> prompts;
}
