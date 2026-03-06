import 'package:flutter/cupertino.dart';

import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../bible/presentation/bible_books_screen.dart';
import '../../journal/presentation/journal_editor_screen.dart';
import '../../journal_prompts/domain/entities/journal_prompt.dart';
import '../../leituras/presentation/pages/leituras_home_page.dart';

class JournalPromptDetailScreen extends StatelessWidget {
  const JournalPromptDetailScreen({super.key, required this.prompt});

  final JournalPrompt prompt;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(prompt.category.label),
        backgroundColor: context.colors.background,
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            IaculaSpacing.md,
            IaculaSpacing.md,
            IaculaSpacing.md,
            IaculaSpacing.md + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IaculaSoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryBadge(label: prompt.category.label),
                    const SizedBox(height: 16),
                    Text(prompt.text, style: context.textStyles.sectionTitle),
                    const SizedBox(height: 12),
                    Text(
                      prompt.category.description,
                      style: context.textStyles.secondary.copyWith(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IaculaSpacing.md),
              IaculaSoftCard(
                child: Text(
                  'Use esta pergunta como ponto de partida. Escreva com liberdade, depois aprofunde nas Leituras ou na Bíblia se isso ajudar sua oração.',
                  style: context.textStyles.secondary.copyWith(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: IaculaSpacing.lg),
              IaculaPrimaryPillButton(
                label: 'Escrever no diário',
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) =>
                          JournalEditorScreen(initialPrompt: prompt),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              IaculaSecondaryPillButton(
                label: 'Abrir Leituras',
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const LeiturasHomePage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              IaculaSecondaryPillButton(
                label: 'Abrir Bíblia',
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const BibleBooksScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.primaryButton.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: context.textStyles.secondary.copyWith(
          color: context.colors.primaryButton,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
