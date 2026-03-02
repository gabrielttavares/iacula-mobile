import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../premium/domain/entities/premium_feature.dart';
import '../../premium/presentation/premium_gate.dart';
import '../domain/entities/journal_entry.dart';
import 'journal_editor_screen.dart';

class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text(
          'Diário Espiritual',
          style: context.textStyles.cardTitle,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.add,
            color: context.colors.primaryButton,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => const JournalEditorScreen(),
              ),
            );
          },
        ),
      ),
      child: PremiumGate(
        feature: PremiumFeature.journal,
        child: _JournalContent(),
      ),
    );
  }
}

class _JournalContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesProvider);

    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.book,
                    size: 48,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Seu diário está vazio',
                    style: context.textStyles.cardTitle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comece a escrever suas reflexões espirituais.',
                    textAlign: TextAlign.center,
                    style: context.textStyles.secondary,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: IaculaSpacing.sm),
          itemBuilder: (context, index) {
            return _JournalEntryCard(entry: entries[index]);
          },
        );
      },
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (_, __) => Center(
        child: Text('Erro ao carregar', style: context.textStyles.secondary),
      ),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(entry.createdAt);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => JournalEditorScreen(entry: entry),
          ),
        );
      },
      child: IaculaSoftCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (entry.mood != null) ...[
                  Text(entry.mood!.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    entry.title ?? dateStr,
                    style: context.textStyles.cardTitle.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  dateStr,
                  style: context.textStyles.secondary.copyWith(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.secondary.copyWith(fontSize: 14),
            ),
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: entry.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.secondaryButton,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: context.textStyles.secondary.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime d) {
  const months = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
