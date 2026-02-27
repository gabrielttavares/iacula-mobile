enum MeditationType { video, audio, text }

enum MeditationAvailabilityKind { evergreen, daily }

final class MeditationItem {
  const MeditationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.categoryTags,
    required this.sourceName,
    required this.availability,
    required this.provenance,
    this.durationSec,
    this.readingTimeSec,
    this.sourceUrl,
    this.mediaUrl,
    this.imageUrl,
    this.dateRef,
    this.textContent,
    this.premiumTier = 'free',
  });

  final String id;
  final MeditationType type;
  final String title;
  final String summary;
  final int? durationSec;
  final int? readingTimeSec;
  final List<String> categoryTags;
  final String sourceName;
  final String? sourceUrl;
  final String? mediaUrl;
  final String? imageUrl;
  final String? dateRef;
  final MeditationAvailability availability;
  final MeditationTextContent? textContent;
  final String premiumTier;
  final MeditationProvenance provenance;

  /// Display duration in minutes for feed badge.
  String? get durationLabel {
    final secs = durationSec ?? readingTimeSec;
    if (secs == null) return null;
    final mins = (secs / 60).ceil();
    return '$mins min';
  }

  /// Estimate reading time from word count (~200 wpm).
  static int estimateReadingTimeSec(String text) {
    final wordCount = text.split(RegExp(r'\s+')).length;
    return (wordCount / 200 * 60).ceil();
  }

  factory MeditationItem.fromJson(Map<String, dynamic> json) {
    final type = MeditationType.values.byName(json['type'] as String);
    final textContentJson = json['textContent'] as Map<String, dynamic>?;
    final textContent = textContentJson != null
        ? MeditationTextContent.fromJson(textContentJson)
        : null;

    final readingTime = json['readingTimeSec'] as int? ??
        (textContent != null
            ? estimateReadingTimeSec(textContent.body)
            : null);

    return MeditationItem(
      id: json['id'] as String,
      type: type,
      title: json['title'] as String,
      summary: json['summary'] as String,
      durationSec: json['durationSec'] as int?,
      readingTimeSec: readingTime,
      categoryTags: (json['categoryTags'] as List<dynamic>)
          .cast<String>(),
      sourceName: json['sourceName'] as String,
      sourceUrl: json['sourceUrl'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      dateRef: json['dateRef'] as String?,
      availability: MeditationAvailability.fromJson(
        json['availability'] as Map<String, dynamic>,
      ),
      textContent: textContent,
      premiumTier: json['premiumTier'] as String? ?? 'free',
      provenance: MeditationProvenance.fromJson(
        json['provenance'] as Map<String, dynamic>,
      ),
    );
  }
}

final class MeditationAvailability {
  const MeditationAvailability({
    required this.kind,
    this.timezone,
  });

  final MeditationAvailabilityKind kind;
  final String? timezone;

  factory MeditationAvailability.fromJson(Map<String, dynamic> json) {
    return MeditationAvailability(
      kind: MeditationAvailabilityKind.values.byName(json['kind'] as String),
      timezone: json['timezone'] as String?,
    );
  }
}

final class MeditationTextContent {
  const MeditationTextContent({
    required this.body,
    required this.format,
    required this.language,
    this.sections,
  });

  final String body;
  final String format; // "markdown" | "html" | "plain"
  final String language;
  final List<MeditationTextSection>? sections;

  factory MeditationTextContent.fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'] as List<dynamic>?;
    return MeditationTextContent(
      body: json['body'] as String,
      format: json['format'] as String? ?? 'plain',
      language: json['language'] as String? ?? 'pt',
      sections: sectionsJson
          ?.map((e) =>
              MeditationTextSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

final class MeditationTextSection {
  const MeditationTextSection({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;

  factory MeditationTextSection.fromJson(Map<String, dynamic> json) {
    return MeditationTextSection(
      heading: json['heading'] as String,
      body: json['body'] as String,
    );
  }
}

final class MeditationProvenance {
  const MeditationProvenance({
    required this.providerId,
    required this.providerType,
  });

  final String providerId;
  final String providerType; // "channel" | "daily_text"

  factory MeditationProvenance.fromJson(Map<String, dynamic> json) {
    return MeditationProvenance(
      providerId: json['providerId'] as String,
      providerType: json['providerType'] as String? ?? 'channel',
    );
  }
}
