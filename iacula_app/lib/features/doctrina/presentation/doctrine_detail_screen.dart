import 'package:flutter/cupertino.dart';

import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/doctrine_entry.dart';

class DoctrineDetailScreen extends StatelessWidget {
  const DoctrineDetailScreen({super.key, required this.entry});

  final DoctrineEntry entry;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(entry.title),
        backgroundColor: IaculaColors.background,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(IaculaSpacing.md),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: IaculaText.sectionTitle,
                ),
                const SizedBox(height: IaculaSpacing.lg),
                Text(
                  entry.content,
                  style: IaculaText.secondary.copyWith(
                    color: IaculaColors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
