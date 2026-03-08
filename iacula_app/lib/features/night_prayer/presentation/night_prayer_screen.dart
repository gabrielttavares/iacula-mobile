import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_progress_bar.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../prayer_activity/domain/entities/prayer_activity_entry.dart';
import '../domain/entities/compline_day.dart';
import '../infrastructure/repositories/asset_compline_repository.dart';

final _complineProvider = FutureProvider<ComplineDay?>((ref) async {
  final repo = AssetComplineRepository();
  return repo.getForDay(DateTime.now().weekday);
});

class NightPrayerScreen extends ConsumerWidget {
  const NightPrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Force dark theme for night prayer
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: CupertinoPageScaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        navigationBar: const CupertinoNavigationBar(
          backgroundColor: Color(0xFF0A0A0A),
          border: null,
          middle: Text(
            'Oração da Noite',
            style: TextStyle(color: CupertinoColors.white),
          ),
        ),
        child: SafeArea(
          child: _NightPrayerContent(),
        ),
      ),
    );
  }
}

class _NightPrayerContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complineAsync = ref.watch(_complineProvider);

    return complineAsync.when(
      data: (compline) {
        if (compline == null) {
          return const Center(
            child: Text(
              'Conteúdo não disponível',
              style: TextStyle(color: CupertinoColors.systemGrey),
            ),
          );
        }
        return _NightPrayerBody(compline: compline);
      },
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (_, __) => const Center(
        child: Text(
          'Erro ao carregar',
          style: TextStyle(color: CupertinoColors.systemGrey),
        ),
      ),
    );
  }
}

class _NightPrayerBody extends ConsumerStatefulWidget {
  const _NightPrayerBody({required this.compline});

  final ComplineDay compline;

  @override
  ConsumerState<_NightPrayerBody> createState() => _NightPrayerBodyState();
}

class _NightPrayerBodyState extends ConsumerState<_NightPrayerBody> {
  int _currentSection = 0;
  late DateTime _startedAt;

  final _sectionNames = <String>[];

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _buildSections();
  }

  void _buildSections() {
    for (final psalm in widget.compline.psalms) {
      _sectionNames.add('Salmo — ${psalm.reference}');
    }
    _sectionNames.add(widget.compline.shortReading.title);
    _sectionNames.add(widget.compline.responsory.title);
    _sectionNames.add(widget.compline.canticle.title);
    _sectionNames.add(widget.compline.collect.title);
    _sectionNames.add(widget.compline.marianAntiphon.title);
  }

  int get _totalSections => _sectionNames.length;

  void _next() {
    HapticFeedback.lightImpact();
    if (_currentSection < _totalSections - 1) {
      setState(() => _currentSection++);
    } else {
      _complete();
    }
  }

  void _previous() {
    if (_currentSection > 0) {
      HapticFeedback.lightImpact();
      setState(() => _currentSection--);
    }
  }

  void _complete() {
    final elapsed = DateTime.now().difference(_startedAt).inSeconds;
    ref.read(prayerActivityLoggerProvider).logActivity(
          type: PrayerActivityType.nightPrayer,
          durationSeconds: elapsed,
          featureSlug: 'compline',
        );

    IaculaModal.showAlert(
      context: context,
      title: 'Completas concluídas',
      message:
          'Boa noite. Descanse na paz de Deus.\nTempo: ${(elapsed / 60).ceil()} minutos.',
      actionLabel: 'Fechar',
    ).then((_) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Widget _buildSectionContent() {
    final psalmCount = widget.compline.psalms.length;

    if (_currentSection < psalmCount) {
      final psalm = widget.compline.psalms[_currentSection];
      return _NightCard(
        title: psalm.reference,
        subtitle: 'Antífona: ${psalm.antiphon}',
        body: psalm.text,
      );
    }

    final adjustedIndex = _currentSection - psalmCount;
    final section = switch (adjustedIndex) {
      0 => widget.compline.shortReading,
      1 => widget.compline.responsory,
      2 => widget.compline.canticle,
      3 => widget.compline.collect,
      4 => widget.compline.marianAntiphon,
      _ => widget.compline.collect,
    };

    return _NightCard(
      title: section.title,
      subtitle: section.reference,
      body: section.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _sectionNames[_currentSection],
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 13,
                ),
              ),
              Text(
                '${_currentSection + 1}/$_totalSections',
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: IaculaProgressBar(
              value: (_currentSection + 1) / _totalSections,
              backgroundColor: const Color(0xFF2C2C2E),
              color: const Color(0xFF6366F1), // Calm purple for night
              minHeight: 4,
            ),
          ),
          const SizedBox(height: IaculaSpacing.lg),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: _buildSectionContent(),
            ),
          ),

          const SizedBox(height: IaculaSpacing.md),

          // Navigation
          Row(
            children: [
              if (_currentSection > 0)
                Expanded(
                  child: CupertinoButton(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(24),
                    onPressed: _previous,
                    child: const Text(
                      'Anterior',
                      style: TextStyle(color: CupertinoColors.white),
                    ),
                  ),
                ),
              if (_currentSection > 0) const SizedBox(width: 12),
              Expanded(
                child: CupertinoButton(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(24),
                  onPressed: _next,
                  child: Text(
                    _currentSection < _totalSections - 1
                        ? 'Continuar'
                        : 'Concluir',
                    style: const TextStyle(color: CupertinoColors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NightCard extends StatelessWidget {
  const _NightCard({
    required this.title,
    this.subtitle,
    required this.body,
  });

  final String title;
  final String? subtitle;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFFCCCCCC),
              fontSize: 17,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}
