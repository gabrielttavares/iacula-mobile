import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../custom_phrases/presentation/edit_phrase_screen.dart';
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
    });
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
