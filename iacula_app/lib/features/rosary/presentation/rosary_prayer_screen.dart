import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/presentation/widgets/iacula_progress_bar.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../prayer_activity/domain/entities/prayer_activity_entry.dart';
import '../domain/entities/rosary_mystery_set.dart';

/// Prayers used in the Rosary (public domain traditional Catholic prayers).
class _RosaryPrayers {
  static const paiNosso =
      'Pai nosso, que estais nos Céus, santificado seja o Vosso Nome, '
      'venha a nós o Vosso Reino, seja feita a Vossa vontade assim na terra como no Céu. '
      'O pão nosso de cada dia nos dai hoje, perdoai-nos as nossas ofensas '
      'assim como nós perdoamos a quem nos tem ofendido, '
      'e não nos deixeis cair em tentação, mas livrai-nos do Mal. Amém.';

  static const aveMaria =
      'Ave Maria, cheia de graça, o Senhor é convosco, '
      'bendita sois vós entre as mulheres e bendito é o fruto do vosso ventre, Jesus. '
      'Santa Maria, Mãe de Deus, rogai por nós pecadores, '
      'agora e na hora da nossa morte. Amém.';

  static const gloria =
      'Glória ao Pai, e ao Filho, e ao Espírito Santo. '
      'Como era no princípio, agora e sempre, e pelos séculos dos séculos. Amém.';

  static const fatimaPrayer =
      'Ó meu Jesus, perdoai-nos, livrai-nos do fogo do inferno, '
      'levai as almas todas para o Céu, principalmente as que mais precisarem '
      'da Vossa Misericórdia.';

  static const salveRainha =
      'Salve Rainha, Mãe de Misericórdia, vida, doçura, esperança nossa, salve! '
      'A vós bradamos, os degredados filhos de Eva. '
      'A vós suspiramos, gemendo e chorando neste vale de lágrimas. '
      'Eia, pois, Advogada nossa, esses vossos olhos misericordiosos a nós volvei. '
      'E depois deste desterro, mostrai-nos Jesus, bendito fruto do vosso ventre. '
      'Ó clemente, ó piedosa, ó doce sempre Virgem Maria. '
      'Rogai por nós, Santa Mãe de Deus, para que sejamos dignos das promessas de Cristo. Amém.';
}

enum _RosaryPhase {
  mysteryIntro,
  paiNosso,
  aveMaria,
  gloria,
  fatima,
  salveRainha,
}

class RosaryPrayerScreen extends ConsumerStatefulWidget {
  const RosaryPrayerScreen({super.key, required this.mysterySet});

  final RosaryMysterySet mysterySet;

  @override
  ConsumerState<RosaryPrayerScreen> createState() => _RosaryPrayerScreenState();
}

class _RosaryPrayerScreenState extends ConsumerState<RosaryPrayerScreen> {
  int _currentDecade = 0;
  int _currentBead = 0; // 0-9 for Ave Marias
  _RosaryPhase _phase = _RosaryPhase.mysteryIntro;
  late DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
  }

  RosaryMystery get _currentMystery =>
      widget.mysterySet.mysteries[_currentDecade];

  bool get _isLastDecade => _currentDecade >= widget.mysterySet.mysteries.length - 1;

  void _advance() {
    HapticFeedback.lightImpact();
    setState(() {
      switch (_phase) {
        case _RosaryPhase.mysteryIntro:
          _phase = _RosaryPhase.paiNosso;
        case _RosaryPhase.paiNosso:
          _currentBead = 0;
          _phase = _RosaryPhase.aveMaria;
        case _RosaryPhase.aveMaria:
          if (_currentBead < 9) {
            _currentBead++;
          } else {
            _phase = _RosaryPhase.gloria;
          }
        case _RosaryPhase.gloria:
          _phase = _RosaryPhase.fatima;
        case _RosaryPhase.fatima:
          if (_isLastDecade) {
            _phase = _RosaryPhase.salveRainha;
          } else {
            _currentDecade++;
            _currentBead = 0;
            _phase = _RosaryPhase.mysteryIntro;
          }
        case _RosaryPhase.salveRainha:
          _completeRosary();
          return;
      }
    });
  }

  void _completeRosary() {
    final elapsed = DateTime.now().difference(_startedAt).inSeconds;
    ref.read(prayerActivityLoggerProvider).logActivity(
          type: PrayerActivityType.rosary,
          durationSeconds: elapsed,
          featureSlug: 'rosary_${widget.mysterySet.type.name}',
        );

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Rosário Completo!'),
        content: Text(
          'Você completou os ${widget.mysterySet.type.label}.\n'
          'Tempo: ${(elapsed / 60).ceil()} minutos.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Concluir'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text(
          widget.mysterySet.type.shortLabel,
          style: context.textStyles.cardTitle,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              _BeadProgress(
                decade: _currentDecade,
                totalDecades: widget.mysterySet.mysteries.length,
                bead: _currentBead,
                totalBeads: 10,
                phase: _phase,
              ),
              const SizedBox(height: IaculaSpacing.lg),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  child: _buildPhaseContent(context),
                ),
              ),

              const SizedBox(height: IaculaSpacing.md),

              // Advance button
              IaculaPrimaryPillButton(
                label: _phase == _RosaryPhase.salveRainha
                    ? 'Concluir Rosário'
                    : 'Continuar',
                onPressed: _advance,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseContent(BuildContext context) {
    return switch (_phase) {
      _RosaryPhase.mysteryIntro => _MysteryIntroCard(
          mystery: _currentMystery,
          decadeNumber: _currentDecade + 1,
        ),
      _RosaryPhase.paiNosso => _PrayerCard(
          title: 'Pai Nosso',
          text: _RosaryPrayers.paiNosso,
        ),
      _RosaryPhase.aveMaria => _PrayerCard(
          title: 'Ave Maria (${_currentBead + 1}/10)',
          text: _RosaryPrayers.aveMaria,
          subtitle: _currentMystery.meditationText,
        ),
      _RosaryPhase.gloria => _PrayerCard(
          title: 'Glória ao Pai',
          text: _RosaryPrayers.gloria,
        ),
      _RosaryPhase.fatima => _PrayerCard(
          title: 'Oração de Fátima',
          text: _RosaryPrayers.fatimaPrayer,
        ),
      _RosaryPhase.salveRainha => _PrayerCard(
          title: 'Salve Rainha',
          text: _RosaryPrayers.salveRainha,
        ),
    };
  }
}

class _BeadProgress extends StatelessWidget {
  const _BeadProgress({
    required this.decade,
    required this.totalDecades,
    required this.bead,
    required this.totalBeads,
    required this.phase,
  });

  final int decade;
  final int totalDecades;
  final int bead;
  final int totalBeads;
  final _RosaryPhase phase;

  @override
  Widget build(BuildContext context) {
    final totalProgress =
        (decade * 10 + (phase == _RosaryPhase.aveMaria ? bead : 0)) /
            (totalDecades * 10);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${decade + 1}ª Dezena',
              style: context.textStyles.secondary.copyWith(fontSize: 13),
            ),
            Text(
              '${(totalProgress * 100).round()}%',
              style: context.textStyles.secondary.copyWith(fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: IaculaProgressBar(
            value: totalProgress,
            backgroundColor: context.colors.systemGray6,
            color: context.colors.primaryButton,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _MysteryIntroCard extends StatelessWidget {
  const _MysteryIntroCard({
    required this.mystery,
    required this.decadeNumber,
  });

  final RosaryMystery mystery;
  final int decadeNumber;

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${decadeNumber}° Mistério',
            style: context.textStyles.secondary.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            mystery.name,
            style: context.textStyles.sectionTitle,
          ),
          const SizedBox(height: 8),
          Text(
            'Fruto: ${mystery.fruit}',
            style: context.textStyles.cardTitle.copyWith(
              color: context.colors.primaryButton,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            mystery.scriptureRef,
            style: context.textStyles.secondary.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mystery.scriptureText,
            style: context.textStyles.secondary.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            mystery.meditationText,
            style: context.textStyles.secondary,
          ),
        ],
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  const _PrayerCard({
    required this.title,
    required this.text,
    this.subtitle,
  });

  final String title;
  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textStyles.sectionTitle,
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: context.textStyles.secondary.copyWith(
              fontSize: 16,
              height: 1.6,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primaryButton.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                subtitle!,
                style: context.textStyles.secondary.copyWith(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
