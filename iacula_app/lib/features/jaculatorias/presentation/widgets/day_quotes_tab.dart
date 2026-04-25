import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../../liturgical/domain/liturgical_season.dart';
import '../../../quotes/domain/entities/day_quotes.dart';
import '../../../custom_phrases/presentation/edit_phrase_screen.dart';

class DayQuotesTab extends ConsumerStatefulWidget {
  const DayQuotesTab({super.key, required this.escrivaEnabled});

  final bool escrivaEnabled;

  @override
  ConsumerState<DayQuotesTab> createState() => _DayQuotesTabState();
}

class _DayQuotesTabState extends ConsumerState<DayQuotesTab> {
  Map<String, DayQuotes>? _quotes;
  final Set<int> _expandedDays = {};

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    final repo = ref.read(quoteContentRepositoryProvider);
    final result = await repo.loadQuotes(
      language: 'pt-br',
      season: LiturgicalSeason.ordinary,
    );
    if (mounted) {
      setState(() => _quotes = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabledAsync = ref.watch(disabledQuotesNotifierProvider);
    final disabledMap = disabledAsync.valueOrNull ?? {};

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.escrivaEnabled)
          Padding(
            padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
            child: IaculaSoftCard(
              padding: const EdgeInsets.symmetric(
                horizontal: IaculaSpacing.md,
                vertical: IaculaSpacing.sm,
              ),
              child: Text(
                'Pontos de Caminho/Sulco/Forja estão ativos. '
                'As jaculatórias padrão estão pausadas.',
                style: context.textStyles.secondary.copyWith(fontSize: 13),
              ),
            ),
          ),
        if (_quotes == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(IaculaSpacing.lg),
              child: CupertinoActivityIndicator(),
            ),
          )
        else
          Opacity(
            opacity: widget.escrivaEnabled ? 0.5 : 1.0,
            child: Column(
              children: [
                for (int iaculaDay = 1; iaculaDay <= 7; iaculaDay++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
                    child: _DaySection(
                      iaculaDay: iaculaDay,
                      dayQuotes: _quotes![iaculaDay.toString()],
                      disabledIndices: disabledMap[iaculaDay] ?? const {},
                      isExpanded: _expandedDays.contains(iaculaDay),
                      actionsEnabled: !widget.escrivaEnabled,
                      onHeaderTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (_expandedDays.contains(iaculaDay)) {
                            _expandedDays.remove(iaculaDay);
                          } else {
                            _expandedDays.add(iaculaDay);
                          }
                        });
                      },
                      onToggle: (quoteIndex) {
                        HapticFeedback.selectionClick();
                        ref
                            .read(disabledQuotesNotifierProvider.notifier)
                            .toggle(
                              dayOfWeek: iaculaDay,
                              quoteIndex: quoteIndex,
                            );
                      },
                      onDelete: (quoteIndex) async {
                        final confirmed = await showCupertinoDialog<bool>(
                          context: context,
                          builder: (ctx) => CupertinoAlertDialog(
                            title: const Text('Apagar jaculatória'),
                            content: const Text(
                              'Após apagar, a única forma de recuperar '
                              'esta jaculatória é adicioná-la novamente '
                              'manualmente. Deseja continuar?',
                            ),
                            actions: [
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              CupertinoDialogAction(
                                isDestructiveAction: true,
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Apagar'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          HapticFeedback.mediumImpact();
                          ref
                              .read(disabledQuotesNotifierProvider.notifier)
                              .toggle(
                                dayOfWeek: iaculaDay,
                                quoteIndex: quoteIndex,
                              );
                        }
                      },
                      onAddPhrase: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const EditPhraseScreen(),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
      ],
    );

    return content;
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.iaculaDay,
    required this.dayQuotes,
    required this.disabledIndices,
    required this.isExpanded,
    required this.actionsEnabled,
    required this.onHeaderTap,
    required this.onToggle,
    required this.onDelete,
    required this.onAddPhrase,
  });

  final int iaculaDay;
  final DayQuotes? dayQuotes;
  final Set<int> disabledIndices;
  final bool isExpanded;
  final bool actionsEnabled;
  final VoidCallback onHeaderTap;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onDelete;
  final VoidCallback onAddPhrase;

  @override
  Widget build(BuildContext context) {
    final quotes = dayQuotes;
    if (quotes == null) return const SizedBox.shrink();

    final total = quotes.quotes.length;
    final enabledCount = total - disabledIndices.length;

    return IaculaSoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(
              horizontal: IaculaSpacing.md,
              vertical: IaculaSpacing.sm,
            ),
            onPressed: onHeaderTap,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quotes.day,
                        style: context.textStyles.cardTitle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        quotes.theme,
                        style: context.textStyles.secondary.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: IaculaSpacing.xs),
                Text(
                  '$enabledCount/$total',
                  style: context.textStyles.secondary.copyWith(fontSize: 13),
                ),
                const SizedBox(width: IaculaSpacing.xs),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            Container(
              height: 0.5,
              color: context.colors.separator,
            ),
            for (int i = 0; i < quotes.quotes.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: IaculaSpacing.md,
                  ),
                  child: Container(
                    height: 0.5,
                    color: context.colors.separator,
                  ),
                ),
              _QuoteRow(
                text: quotes.quotes[i],
                isDisabled: disabledIndices.contains(i),
                actionsEnabled: actionsEnabled,
                onToggle: () => onToggle(i),
                onDelete: () => onDelete(i),
              ),
            ],
            Container(
              height: 0.5,
              color: context.colors.separator,
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(
                horizontal: IaculaSpacing.md,
                vertical: IaculaSpacing.xs,
              ),
              onPressed: onAddPhrase,
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.add_circled,
                    size: 18,
                    color: context.colors.primaryButton,
                  ),
                  const SizedBox(width: IaculaSpacing.xs),
                  Text(
                    'Adicionar frase personalizada',
                    style: context.textStyles.secondary.copyWith(
                      color: context.colors.primaryButton,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuoteRow extends StatefulWidget {
  const _QuoteRow({
    required this.text,
    required this.isDisabled,
    required this.actionsEnabled,
    required this.onToggle,
    required this.onDelete,
  });

  final String text;
  final bool isDisabled;
  final bool actionsEnabled;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  State<_QuoteRow> createState() => _QuoteRowState();
}

class _QuoteRowState extends State<_QuoteRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        Clipboard.setData(ClipboardData(text: widget.text));
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            content: const Text('Texto copiado!'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: IaculaSpacing.md,
            vertical: IaculaSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Opacity(
                  opacity: widget.isDisabled ? 0.4 : 1.0,
                  child: Text(
                    widget.text,
                    maxLines: _expanded ? null : 2,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                    style: context.textStyles.secondary.copyWith(
                      fontSize: 14,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: IaculaSpacing.xs),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(28, 28),
                onPressed: widget.actionsEnabled ? widget.onToggle : null,
                child: Icon(
                  widget.isDisabled
                      ? CupertinoIcons.circle
                      : CupertinoIcons.checkmark_circle_fill,
                  size: 22,
                  color: widget.actionsEnabled
                      ? (widget.isDisabled
                          ? context.colors.textSecondary
                          : context.colors.primaryButton)
                      : context.colors.textSecondary.withValues(alpha: 0.4),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(28, 28),
                onPressed: widget.actionsEnabled ? widget.onDelete : null,
                child: Icon(
                  CupertinoIcons.trash,
                  size: 18,
                  color: widget.actionsEnabled
                      ? CupertinoColors.destructiveRed
                      : CupertinoColors.destructiveRed
                          .withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
