import 'package:flutter/material.dart';
import 'widgets/meditation_card.dart';

class MeditationScreen extends StatelessWidget {
  const MeditationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1A17),
      appBar: AppBar(
        title: Text(
          'Meditação Diária',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFD6BA8E),
              ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFD6BA8E),
        elevation: 0,
        centerTitle: true,
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
