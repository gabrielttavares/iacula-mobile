import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/last_delivered_card.dart';

final _lastCardProvider = FutureProvider<LastDeliveredCard?>((ref) {
  return ref.watch(lastDeliveredCardRepositoryProvider).load();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardAsync = ref.watch(_lastCardProvider);

    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Notificações'),
      ),
      child: SafeArea(
        child: cardAsync.when(
          data: (card) {
            if (card == null) {
              return Center(
                child: Text(
                  'Nenhuma notificação ainda.',
                  style: IaculaText.secondary,
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(IaculaSpacing.md),
              children: [
                const IaculaLargeTitle('Última notificação'),
                const SizedBox(height: IaculaSpacing.md),
                IaculaSoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.theme, style: IaculaText.secondary),
                      const SizedBox(height: 8),
                      Text(card.quoteText, style: IaculaText.cardTitle),
                      const SizedBox(height: 12),
                      Text(
                        _formatDate(card.deliveredAt),
                        style: IaculaText.secondary,
                      ),
                      if (card.feastName != null) ...[
                        const SizedBox(height: 4),
                        Text(card.feastName!, style: IaculaText.secondary),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_, __) => Center(
            child: Text('Erro ao carregar notificações.', style: IaculaText.secondary),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
