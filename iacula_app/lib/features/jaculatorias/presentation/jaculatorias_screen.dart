import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../custom_phrases/presentation/edit_phrase_screen.dart';
import '../../liturgical/domain/liturgical_season.dart';
import 'widgets/custom_phrases_tab.dart';
import 'widgets/day_quotes_tab.dart';

class JaculatoriasScreen extends ConsumerStatefulWidget {
  const JaculatoriasScreen({super.key});

  @override
  ConsumerState<JaculatoriasScreen> createState() => _JaculatoriasScreenState();
}

class _JaculatoriasScreenState extends ConsumerState<JaculatoriasScreen> {
  int _selectedTab = 0;
  bool _escrivaPointsFeedEnabled = false;
  bool _escrivaPointsFeedOptionVisible = false;
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ref.read(getSettingsUseCaseProvider).call();
    if (!mounted) return;
    setState(() {
      _escrivaPointsFeedEnabled = settings.escrivaPointsFeedEnabled;
      _escrivaPointsFeedOptionVisible = settings.escrivaPointsFeedOptionVisible;
      _settingsLoaded = true;
    });
  }

  Future<void> _toggleEscrivaFeed(bool value) async {
    final previous = _escrivaPointsFeedEnabled;
    setState(() => _escrivaPointsFeedEnabled = value);

    try {
      final current = await ref.read(getSettingsUseCaseProvider).call();
      final updated = current.copyWith(escrivaPointsFeedEnabled: value);
      await ref.read(updateSettingsUseCaseProvider).call(updated);

      final season =
          await ref.read(liturgicalSeasonServiceProvider).getCurrentSeason();
      await ref.read(rebuildNotificationsUseCaseProvider).call(
        updated,
        isEasterSeason: season == LiturgicalSeason.easter,
        showImmediate: false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _escrivaPointsFeedEnabled = previous);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: context.colors.background,
            border: null,
            largeTitle: const Text('Jaculatórias'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(32, 32),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => const EditPhraseScreen(),
                  ),
                );
              },
              child: Icon(
                CupertinoIcons.add,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          if (_escrivaPointsFeedOptionVisible)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: IaculaSoftCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pontos de Caminho/Sulco/Forja',
                              style: context.textStyles.cardTitle.copyWith(
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Usa estes conteúdos no lugar das jaculatórias.',
                              style: context.textStyles.secondary.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      CupertinoSwitch(
                        value: _escrivaPointsFeedEnabled,
                        onChanged: _settingsLoaded
                            ? (value) {
                                HapticFeedback.selectionClick();
                                _toggleEscrivaFeed(value);
                              }
                            : null,
                        activeTrackColor: context.colors.primaryButton,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: _selectedTab,
                  children: const {
                    0: Text('Por Dia', style: TextStyle(fontSize: 13)),
                    1: Text('Minhas', style: TextStyle(fontSize: 13)),
                  },
                  onValueChanged: (value) {
                    if (value != null) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedTab = value);
                    }
                  },
                ),
              ),
            ),
          ),
          if (_selectedTab == 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  28 + MediaQuery.paddingOf(context).bottom,
                ),
                child: DayQuotesTab(
                  escrivaEnabled: _escrivaPointsFeedEnabled,
                ),
              ),
            )
          else
            const CustomPhrasesTab(),
        ],
      ),
    );
  }
}
