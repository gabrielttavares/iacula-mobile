import 'package:flutter/cupertino.dart';

import '../../../core/theme/cupertino_tokens.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(IaculaSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IaculaLargeTitle('Favoritos'),
              SizedBox(height: IaculaSpacing.md),
              Text(
                'Seus itens salvos aparecerão aqui.',
                style: IaculaText.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
