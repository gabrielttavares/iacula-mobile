import 'package:flutter/cupertino.dart';

import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: context.colors.primaryButton),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.textStyles.sectionTitle,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.textStyles.secondary.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
