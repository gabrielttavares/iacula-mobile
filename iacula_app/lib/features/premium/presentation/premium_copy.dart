import '../domain/entities/premium_feature.dart';

final class PremiumCopy {
  const PremiumCopy({
    required this.featureTitle,
    required this.gateMessage,
  });

  final String featureTitle;
  final String gateMessage;
}

PremiumCopy premiumCopyFor(PremiumFeature feature) {
  return switch (feature) {
    PremiumFeature.meditation => const PremiumCopy(
      featureTitle: 'Meditações',
      gateMessage:
          'Abra meditações guiadas, leitura em modo foco e conteúdos para recolher o coração todos os dias.',
    ),
    PremiumFeature.planOfLife => const PremiumCopy(
      featureTitle: 'Plano de vida',
      gateMessage:
          'Organize pequenas práticas espirituais e acompanhe sua constância com mais profundidade.',
    ),
    PremiumFeature.streakDashboard => const PremiumCopy(
      featureTitle: 'Painel espiritual',
      gateMessage:
          'Veja sua constância de oração e acompanhe seu caminho com mais clareza.',
    ),
    PremiumFeature.rosary => const PremiumCopy(
      featureTitle: 'Rosário guiado',
      gateMessage:
          'Reze cada mistério com textos, imagens e ritmo guiado dentro do app.',
    ),
    PremiumFeature.leituras => const PremiumCopy(
      featureTitle: 'Leituras',
      gateMessage:
          'Acesse leituras espirituais completas para prolongar sua oração ao longo do dia.',
    ),
    PremiumFeature.journal => const PremiumCopy(
      featureTitle: 'Diário espiritual',
      gateMessage:
          'Guarde resoluções, reflexões e graças recebidas no seu caminho de oração.',
    ),
    PremiumFeature.nightPrayer => const PremiumCopy(
      featureTitle: 'Oração da noite',
      gateMessage:
          'Feche o dia em recolhimento com uma oração noturna guiada.',
    ),
    PremiumFeature.liturgyOfHours => const PremiumCopy(
      featureTitle: 'Liturgia das Horas',
      gateMessage:
          'Acompanhe as horas principais com textos preparados para a sua rotina.',
    ),
    PremiumFeature.widgets => const PremiumCopy(
      featureTitle: 'Widgets',
      gateMessage:
          'Leve reflexões, santo do dia e lembretes espirituais para a tela inicial.',
    ),
  };
}
