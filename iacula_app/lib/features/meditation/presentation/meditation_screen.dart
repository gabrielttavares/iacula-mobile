import 'package:flutter/cupertino.dart';

import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/theme/cupertino_tokens.dart';
import 'widgets/meditation_card.dart';

class MeditationScreen extends StatelessWidget {
  const MeditationScreen({super.key});

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
              IaculaLargeTitle('Homilias'),
              SizedBox(height: IaculaSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      MeditationCard(
                        title: 'Padre Cléber Eduardo dos Santos Dias',
                        platformIcon: CupertinoIcons.mic,
                        url: 'https://soundcloud.com/praedicaverbum',
                      ),
                      SizedBox(height: 12),
                      MeditationCard(
                        title: 'Homilia Diária Padre Paulo Ricardo',
                        platformIcon: CupertinoIcons.play_circle,
                        url:
                            'https://www.youtube.com/@padrepauloricardo/videos',
                      ),
                      SizedBox(height: 12),
                      MeditationCard(
                        title: 'Padre Pedro Willemsens',
                        platformIcon: CupertinoIcons.play_circle,
                        url: 'https://www.youtube.com/@meditacoespadrepedro',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
