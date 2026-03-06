import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../prayer_activity/domain/entities/prayer_activity_entry.dart';
import '../domain/entities/journal_entry.dart';
import '../../journal_prompts/domain/entities/journal_prompt.dart';

class JournalEditorScreen extends ConsumerStatefulWidget {
  const JournalEditorScreen({super.key, this.entry, this.initialPrompt});

  final JournalEntry? entry;
  final JournalPrompt? initialPrompt;

  @override
  ConsumerState<JournalEditorScreen> createState() =>
      _JournalEditorScreenState();
}

class _JournalEditorScreenState extends ConsumerState<JournalEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final TextEditingController _tagController;
  JournalMood? _mood;
  final List<String> _tags = [];
  late DateTime _startedAt;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _titleController = TextEditingController(text: widget.entry?.title);
    _bodyController = TextEditingController(text: widget.entry?.body);
    _tagController = TextEditingController();
    _mood = widget.entry?.mood;
    _tags.addAll(widget.entry?.tags ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_bodyController.text.trim().isEmpty) return;

    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    final entry = JournalEntry(
      id: widget.entry?.id ?? const Uuid().v4(),
      title: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : null,
      body: _bodyController.text.trim(),
      tags: _tags,
      mood: _mood,
      createdAt: widget.entry?.createdAt ?? now,
      updatedAt: now,
    );

    await ref.read(journalRepositoryProvider).save(entry);
    ref.invalidate(journalEntriesProvider);

    // Log activity
    final elapsed = DateTime.now().difference(_startedAt).inSeconds;
    ref
        .read(prayerActivityLoggerProvider)
        .logActivity(
          type: PrayerActivityType.journal,
          durationSeconds: elapsed,
          featureSlug: 'journal',
        );

    if (mounted) Navigator.of(context).pop();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text(
          _isEditing ? 'Editar Entrada' : 'Nova Entrada',
          style: context.textStyles.cardTitle,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _save,
          child: Text(
            'Salvar',
            style: context.textStyles.cardTitle.copyWith(
              color: context.colors.primaryButton,
              fontSize: 16,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.initialPrompt != null) ...[
                IaculaSoftCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.initialPrompt!.category.label,
                        style: context.textStyles.secondary.copyWith(
                          color: context.colors.primaryButton,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.initialPrompt!.text,
                        style: context.textStyles.cardTitle.copyWith(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: IaculaSpacing.md),
              ],
              // Mood selector
              IaculaSoftCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Como está seu espírito?',
                      style: context.textStyles.secondary.copyWith(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: JournalMood.values.map((mood) {
                        final isSelected = _mood == mood;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _mood = isSelected ? null : mood;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.colors.primaryButton.withValues(
                                      alpha: 0.15,
                                    )
                                  : context.colors.systemGray6,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? Border.all(
                                      color: context.colors.primaryButton,
                                    )
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  mood.emoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  mood.label,
                                  style: context.textStyles.secondary.copyWith(
                                    fontSize: 13,
                                    color: isSelected
                                        ? context.colors.primaryButton
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IaculaSpacing.md),

              // Title
              CupertinoTextField(
                controller: _titleController,
                placeholder: 'Título (opcional)',
                style: context.textStyles.cardTitle,
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
              ),
              const SizedBox(height: IaculaSpacing.sm),

              // Body
              CupertinoTextField(
                controller: _bodyController,
                placeholder: 'Escreva sua reflexão...',
                style: context.textStyles.secondary.copyWith(
                  color: context.colors.textPrimary,
                  fontSize: 16,
                  height: 1.6,
                ),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                maxLines: null,
                minLines: 10,
              ),
              const SizedBox(height: IaculaSpacing.md),

              // Tags
              IaculaSoftCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: context.textStyles.secondary.copyWith(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _tags.map((tag) {
                          return GestureDetector(
                            onTap: () => setState(() => _tags.remove(tag)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.primaryButton.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tag,
                                    style: context.textStyles.secondary
                                        .copyWith(
                                          fontSize: 13,
                                          color: context.colors.primaryButton,
                                        ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    CupertinoIcons.xmark_circle_fill,
                                    size: 14,
                                    color: context.colors.primaryButton,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoTextField(
                            controller: _tagController,
                            placeholder: 'Adicionar tag',
                            style: context.textStyles.secondary.copyWith(
                              color: context.colors.textPrimary,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.systemGray6,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _addTag,
                          child: Icon(
                            CupertinoIcons.add_circled,
                            color: context.colors.primaryButton,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
