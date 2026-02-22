import 'package:flutter/material.dart';
import 'widgets/meditation_card.dart';

class MeditationScreen extends StatelessWidget {
  const MeditationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meditação Diária',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: const [
          MeditationCard(
            title: 'Padre Cléber Eduardo dos Santos Dias',
            platformIcon: Icons.podcasts_rounded,
            url: 'https://soundcloud.com/praedicaverbum',
          ),
          MeditationCard(
            title: 'Homilia Diária Padre Paulo Ricardo',
            platformIcon: Icons.play_circle_fill_rounded,
            url: 'https://www.youtube.com/@padrepauloricardo/videos',
          ),
          MeditationCard(
            title: 'Padre Pedro Willemsens',
            platformIcon: Icons.play_circle_fill_rounded,
            url: 'https://www.youtube.com/@meditacoespadrepedro',
          ),
        ],
      ),
    );
  }
}
