import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/cupertino_tokens.dart';
import 'widgets/day_quotes_tab.dart';

class BuiltinQuotesScreen extends ConsumerStatefulWidget {
  const BuiltinQuotesScreen({super.key});

  @override
  ConsumerState<BuiltinQuotesScreen> createState() =>
      _BuiltinQuotesScreenState();
}

class _BuiltinQuotesScreenState extends ConsumerState<BuiltinQuotesScreen> {
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
            largeTitle: const Text('Jaculatórias Padrão'),
          ),
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
          ),
        ],
      ),
    );
  }
}
