import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/rosary_mystery_set.dart';
import 'rosary_mystery_set_screen.dart';
import 'widgets/ken_burns_image.dart';

class RosaryIntroScreen extends ConsumerWidget {
  const RosaryIntroScreen({super.key, this.mysterySet, this.allMysterySets});

  final RosaryMysterySet? mysterySet;
  final List<RosaryMysterySet>? allMysterySets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mysterySet != null) {
      return _RosaryIntroView(
        mysterySet: mysterySet!,
        allMysterySets: allMysterySets,
      );
    }

    final todayType = RosaryMysteryTypeX.forDay(DateTime.now());
    final asyncSet = ref.watch(rosaryMysterySetProvider(todayType));

    return asyncSet.when(
      data: (set) {
        if (set == null) {
          return CupertinoPageScaffold(
            child: Center(
              child: Text(
                'Conteudo do rosario indisponivel',
                style: context.textStyles.secondary,
              ),
            ),
          );
        }
        return _RosaryIntroView(
          mysterySet: set,
          allMysterySets: allMysterySets,
        );
      },
      loading: () => const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (_, __) => const CupertinoPageScaffold(
        child: Center(child: Text('Erro ao carregar rosario')),
      ),
    );
  }
}

class _RosaryIntroView extends ConsumerWidget {
  const _RosaryIntroView({required this.mysterySet, this.allMysterySets});

  final RosaryMysterySet mysterySet;
  final List<RosaryMysterySet>? allMysterySets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            key: const Key('rosary-intro-tap-target'),
            onTap: () => _openSet(context, mysterySet),
            child: KenBurnsImage(
              imagePath: mysterySet.setImagePath,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0x00000000),
                      const Color(0x00000000),
                      const Color(0x99000000),
                    ],
                    stops: const [0.0, 0.58, 1.0],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    minSize: 32,
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Icon(
                      CupertinoIcons.chevron_down,
                      color: Color(0xCCFFFFFF),
                    ),
                  ),
                  CupertinoButton(
                    key: const Key('rosary-intro-overflow'),
                    padding: const EdgeInsets.all(8),
                    minSize: 32,
                    onPressed: () => _showAllMysterySets(context, ref),
                    child: const Icon(
                      CupertinoIcons.ellipsis,
                      color: Color(0xCCFFFFFF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 52),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mysterySet.type.label,
                      textAlign: TextAlign.center,
                      style: context.textStyles.sectionTitle.copyWith(
                        color: const Color(0xFFFFFFFF),
                        fontSize: 34,
                        shadows: const [
                          Shadow(color: Color(0x99000000), blurRadius: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _weekdayLabel(mysterySet.type),
                      textAlign: TextAlign.center,
                      style: context.textStyles.secondary.copyWith(
                        color: const Color(0xCCFFFFFF),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayLabel(RosaryMysteryType type) {
    return switch (type) {
      RosaryMysteryType.joyful => 'Segunda-feira e Sabado',
      RosaryMysteryType.sorrowful => 'Terca-feira e Sexta-feira',
      RosaryMysteryType.glorious => 'Quarta-feira e Domingo',
      RosaryMysteryType.luminous => 'Quinta-feira',
    };
  }

  Future<void> _showAllMysterySets(BuildContext context, WidgetRef ref) async {
    final List<RosaryMysterySet> sets =
        allMysterySets ?? await ref.read(allRosaryMysterySetProvider.future);
    if (!context.mounted) return;

    await IaculaModal.showSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(IaculaSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ver todos os mistérios',
                style: context.textStyles.sectionTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IaculaSpacing.md),
              for (final set in sets) ...[
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    HapticFeedback.lightImpact();
                    _openSet(context, set);
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: KenBurnsImage(imagePath: set.setImagePath),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(set.type.label)),
                    ],
                  ),
                ),
                const SizedBox(height: IaculaSpacing.xs),
              ],
              CupertinoButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSet(BuildContext context, RosaryMysterySet set) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => RosaryMysterySetScreen(mysterySet: set),
      ),
    );
  }
}
