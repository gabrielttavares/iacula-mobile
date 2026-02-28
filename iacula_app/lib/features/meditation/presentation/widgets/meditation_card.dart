import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';

class MeditationCard extends StatelessWidget {
  const MeditationCard({
    super.key,
    required this.title,
    required this.platformIcon,
    required this.url,
  });

  final String title;
  final IconData platformIcon;
  final String url;

  Future<void> _launchUrl(BuildContext context) async {
    final parsedUrl = Uri.parse(url);
    if (!await launchUrl(parsedUrl) && context.mounted) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Erro'),
          content: const Text('Não foi possível abrir o link.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchUrl(context),
      child: IaculaSoftCard(
        radius: 16,
        child: Row(
          children: [
            Icon(platformIcon, color: context.colors.primaryButton, size: 28),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: context.textStyles.cardTitle)),
            Icon(
              CupertinoIcons.chevron_right,
              color: context.colors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
