import 'package:flutter/cupertino.dart';

import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../liturgical/domain/liturgical_season.dart';
import '../../quotes/domain/entities/quote.dart';

final class HeroReflectionSheet {
  HeroReflectionSheet._();

  static const _seasonReflections = <LiturgicalSeason, String>{
    LiturgicalSeason.ordinary:
        'Os cards do início acompanham o Tempo Comum e o ritmo cotidiano da Igreja. '
        'Cada dia oferece uma jaculatória ou breve reflexão para sustentar a oração no meio do trabalho.',
    LiturgicalSeason.advent:
        'Os cards refletem a espera e a preparação do Advento. '
        'São um convite a vigiar e a preparar o coração para a vinda do Senhor.',
    LiturgicalSeason.lent:
        'Os cards acompanham a Quaresma: conversão, jejum e preparação para a Páscoa. '
        'As reflexões ajudam a percorrer esse caminho com o coração voltado para Deus.',
    LiturgicalSeason.easter:
        'Os cards celebram o Tempo Pascal e a alegria da Ressurreição. '
        'Mantêm viva no cotidiano a luz do Cristo ressuscitado.',
    LiturgicalSeason.christmas:
        'Os cards refletem o Natal e a manifestação do Senhor. '
        'Ajudam a prolongar no dia a dia a alegria do Deus que se fez próximo.',
  };

  static const _notificationExplainer =
      'O Iacula envia-te este conteúdo como notificação, no intervalo que escolheste. '
      'A cada notificação recebes uma jaculatória diferente, para que voltes a Deus '
      'durante o dia sem interromper o que estás a fazer.\n\n'
      'Podes alterar a frequência em Configurações > Notificações.';

  static const _exclusivityBody =
      'O Iacula foi pensado para ajudar você a manter viva a oração breve no meio '
      'das tarefas normais do dia. Uma jaculatória, um versículo, um lembrete discreto '
      'e o coração volta a Deus sem romper o ritmo do dever.\n\n'
      'Inspirado na espiritualidade do trabalho santificado, o app procura acompanhar você '
      'nos momentos certos. Como escreveu São Josemaria Escrivá: '
      '"Transforma os deveres do teu estado em oração e em encontro com Deus."';

  static Future<void> show(BuildContext context, {required Quote quote}) {
    return IaculaModal.showSheet<void>(
      context: context,
      maxHeightFraction: 0.85,
      builder: (context) => _HeroReflectionContent(quote: quote),
    );
  }
}

class _HeroReflectionContent extends StatelessWidget {
  const _HeroReflectionContent({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final reflectionText =
        HeroReflectionSheet._seasonReflections[quote.season] ??
        HeroReflectionSheet._seasonReflections[LiturgicalSeason.ordinary]!;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        IaculaSpacing.md,
        IaculaSpacing.lg,
        IaculaSpacing.md,
        IaculaSpacing.xl + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Como funcionam as notificações',
            style: context.textStyles.sectionTitle,
          ),
          const SizedBox(height: IaculaSpacing.sm),
          Text(
            HeroReflectionSheet._notificationExplainer,
            style: context.textStyles.secondary,
          ),
          const SizedBox(height: IaculaSpacing.xl),
          Text(
            'Os cards e o tempo litúrgico',
            style: context.textStyles.sectionTitle,
          ),
          const SizedBox(height: IaculaSpacing.sm),
          Text(reflectionText, style: context.textStyles.secondary),
          const SizedBox(height: IaculaSpacing.xl),
          Text(
            'O que torna o Iacula único',
            style: context.textStyles.sectionTitle,
          ),
          const SizedBox(height: IaculaSpacing.sm),
          Text(
            HeroReflectionSheet._exclusivityBody,
            style: context.textStyles.secondary,
          ),
        ],
      ),
    );
  }
}
