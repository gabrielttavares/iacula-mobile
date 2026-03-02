// lib/features/prayer_intentions/presentation/responded_intentions_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/cupertino_tokens.dart';
import 'widgets/intention_row.dart';

class RespondedIntentionsScreen extends ConsumerWidget {
  const RespondedIntentionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerIntentionsNotifierProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: context.colors.background,
            border: null,
            largeTitle: const Text('Intenções Respondidas'),
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              ref.invalidate(prayerIntentionsNotifierProvider);
              await Future.delayed(const Duration(milliseconds: 500));
            },
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16, 12, 16,
              28 + MediaQuery.paddingOf(context).bottom,
            ),
            sliver: state.respondedIntentions.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Nenhuma intenção respondida ainda.',
                        style: context.textStyles.secondary,
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final intention = state.respondedIntentions[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: IaculaSpacing.sm,
                          ),
                          child: IntentionRow(
                            intention: intention,
                            showRespondedDate: true,
                          ),
                        );
                      },
                      childCount: state.respondedIntentions.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
