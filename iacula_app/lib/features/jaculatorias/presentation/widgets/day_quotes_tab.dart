import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../../liturgical/domain/liturgical_season.dart';
import '../../../quotes/domain/entities/day_quotes.dart';
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
  });

  final int iaculaDay;
  final DayQuotes? dayQuotes;
  final Set<int> disabledIndices;
  final bool isExpanded;
  final bool actionsEnabled;
  final VoidCallback onHeaderTap;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onDelete;

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

class _QuoteRowState extends State<_QuoteRow>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  static const _actionsWidth = 120.0;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-_actionsWidth, 0),
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.actionsEnabled) return;
    final delta = details.primaryDelta ?? 0;
    _slideController.value += -delta / _actionsWidth;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.actionsEnabled) return;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300 || _slideController.value > 0.5) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  void _closeActions() {
    _slideController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onToggle();
                      _closeActions();
                    },
                    child: Container(
                      width: 60,
                      color: widget.isDisabled
                          ? context.colors.primaryButton
                          : CupertinoColors.systemGrey,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.isDisabled
                                ? CupertinoIcons.checkmark_circle
                                : CupertinoIcons.eye_slash,
                            color: CupertinoColors.white,
                            size: 20,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.isDisabled ? 'Ativar' : 'Desativar',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _closeActions();
                      widget.onDelete();
                    },
                    child: Container(
                      width: 60,
                      color: CupertinoColors.destructiveRed,
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.trash,
                            color: CupertinoColors.white,
                            size: 20,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Apagar',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: _slideAnimation.value,
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: () {
                  if (_slideController.value > 0) {
                    _closeActions();
                  } else {
                    setState(() => _expanded = !_expanded);
                  }
                },
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
                onHorizontalDragUpdate: _handleDragUpdate,
                onHorizontalDragEnd: _handleDragEnd,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: context.colors.card,
                  padding: const EdgeInsets.symmetric(
                    horizontal: IaculaSpacing.md,
                    vertical: IaculaSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Opacity(
                          opacity: widget.isDisabled ? 0.4 : 1.0,
                          child: Text(
                            widget.text,
                            maxLines: _expanded ? null : 2,
                            overflow:
                                _expanded ? null : TextOverflow.ellipsis,
                            style: context.textStyles.secondary.copyWith(
                              fontSize: 14,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      if (widget.isDisabled)
                        Padding(
                          padding:
                              const EdgeInsets.only(left: IaculaSpacing.xs),
                          child: Icon(
                            CupertinoIcons.eye_slash,
                            size: 14,
                            color: context.colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
