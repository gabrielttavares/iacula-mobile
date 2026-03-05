import 'package:flutter/cupertino.dart';

import '../../../../core/theme/cupertino_tokens.dart';
import '../../../premium/domain/entities/premium_feature.dart';
import '../../../premium/presentation/premium_gate.dart';
import 'book_list_page.dart';

class LeiturasHomePage extends StatelessWidget {
  const LeiturasHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: const CupertinoNavigationBar(middle: Text('Leituras')),
      child: PremiumGate(
        feature: PremiumFeature.leituras,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(IaculaSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Leituras', style: context.textStyles.largeTitle),
                const SizedBox(height: IaculaSpacing.sm),
                Text(
                  'Livros de São Josemaría Escrivá disponíveis offline.',
                  style: context.textStyles.secondary,
                ),
                const SizedBox(height: IaculaSpacing.lg),
                CupertinoButton.filled(
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const BookListPage(
                          authorName: 'São Josemaría Escrivá',
                          title: 'São Josemaría Escrivá',
                        ),
                      ),
                    );
                  },
                  child: const Text('São Josemaría Escrivá'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
