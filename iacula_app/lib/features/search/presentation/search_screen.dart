import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../liturgical/domain/liturgical_season.dart';
import '../../prayers/presentation/prayer_catalog_detail_screen.dart';
import '../application/app_search_service.dart';

enum _SearchFilter { all, prayers, quotes, readings }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';
  List<AppSearchResult> _results = [];
  final TextEditingController _controller = TextEditingController();
  final List<String> _recentQueries = [];
  bool _loading = false;
  _SearchFilter _selectedFilter = _SearchFilter.all;
  List<String> _seasonalSuggestions = const [
    'pai nosso',
    'perdao',
    'contricao',
    'rosario',
    'gratidao',
  ];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadSeasonalSuggestions();
  }

  Future<void> _loadSeasonalSuggestions() async {
    try {
      final season = await ref
          .read(liturgicalSeasonServiceProvider)
          .getCurrentSeason();
      if (!mounted) {
        return;
      }
      setState(() {
        _seasonalSuggestions = _suggestionsForSeason(season);
      });
    } catch (_) {
      // Keep default suggestions if season lookup fails.
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _results = [];
        _loading = false;
        _query = query;
      });
      return;
    }

    setState(() {
      _loading = true;
      _query = query;
    });

    final settingsUseCase = ref.read(getSettingsUseCaseProvider);
    final settings = await settingsUseCase.call();
    final results = await ref
        .read(appSearchServiceProvider)
        .search(query: query, language: settings.language);

    setState(() {
      _results = results;
      _loading = false;
      _rememberQuery(query);
    });
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      _search(query);
    });
  }

  void _onSuggestionPressed(String suggestion) {
    _controller.value = TextEditingValue(
      text: suggestion,
      selection: TextSelection.collapsed(offset: suggestion.length),
    );
    _onQueryChanged(suggestion);
  }

  void _rememberQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return;
    }
    _recentQueries.remove(trimmed);
    _recentQueries.insert(0, trimmed);
    if (_recentQueries.length > 5) {
      _recentQueries.removeLast();
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedResults = _applyFilter(_groupResults(_results));
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: const CupertinoNavigationBar(middle: Text('Buscar')),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(IaculaSpacing.md),
                child: CupertinoSearchTextField(
                  controller: _controller,
                  placeholder: 'Busque por oração, leitura ou citação',
                  onChanged: _onQueryChanged,
                ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _query.trim().length < 2
                  ? SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: IaculaSpacing.md,
                        right: IaculaSpacing.md,
                        bottom:
                            MediaQuery.paddingOf(context).bottom +
                            IaculaSpacing.md,
                      ),
                      child: _DiscoveryState(
                        recentQueries: _recentQueries,
                        suggestions: _seasonalSuggestions,
                        onSuggestionPressed: _onSuggestionPressed,
                      ),
                    )
                  : _results.isEmpty
                  ? Center(
                      child: IaculaEmptyState(
                        title: 'Nada encontrado',
                        message:
                            'Tente outro termo ou busque por santo, tema ou título.',
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.only(
                        left: IaculaSpacing.md,
                        right: IaculaSpacing.md,
                        bottom:
                            MediaQuery.paddingOf(context).bottom +
                            IaculaSpacing.md,
                      ),
                      itemCount: groupedResults.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return _FilterControl(
                            selectedFilter: _selectedFilter,
                            onChanged: (filter) {
                              setState(() => _selectedFilter = filter);
                            },
                          );
                        }
                        final section = groupedResults[i - 1];
                        return _ResultSection(
                          title: section.$1,
                          results: section.$2,
                          onTap: _openResult,
                          showSearchLabel: i == 1,
                          query: _query,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<(String, List<AppSearchResult>)> _groupResults(
    List<AppSearchResult> results,
  ) {
    final grouped = <String, List<AppSearchResult>>{};
    for (final result in results) {
      grouped
          .putIfAbsent(result.sectionTitle, () => <AppSearchResult>[])
          .add(result);
    }
    return grouped.entries.map((entry) => (entry.key, entry.value)).toList();
  }

  List<(String, List<AppSearchResult>)> _applyFilter(
    List<(String, List<AppSearchResult>)> grouped,
  ) {
    if (_selectedFilter == _SearchFilter.all) {
      return grouped;
    }
    return grouped
        .where((section) => _matchesFilter(section.$1))
        .toList(growable: false);
  }

  bool _matchesFilter(String sectionTitle) {
    final normalized = sectionTitle.toLowerCase();
    switch (_selectedFilter) {
      case _SearchFilter.all:
        return true;
      case _SearchFilter.prayers:
        return normalized == 'orações' || normalized == 'oracoes';
      case _SearchFilter.quotes:
        return normalized == 'citações' || normalized == 'citacoes';
      case _SearchFilter.readings:
        return normalized == 'leituras';
    }
  }

  List<String> _suggestionsForSeason(LiturgicalSeason season) {
    switch (season) {
      case LiturgicalSeason.advent:
        return const ['advento', 'maranata', 'esperanca', 'vigiai', 'encarnacao'];
      case LiturgicalSeason.lent:
        return const ['quaresma', 'penitencia', 'jejum', 'conversao', 'contricao'];
      case LiturgicalSeason.easter:
        return const ['pascoa', 'ressurreicao', 'aleluia', 'regina caeli', 'vida nova'];
      case LiturgicalSeason.christmas:
        return const ['natal', 'encarnacao', 'menino jesus', 'sagrada familia', 'paz'];
      case LiturgicalSeason.ordinary:
        return const ['pai nosso', 'gratidao', 'rosario', 'fe', 'caridade'];
    }
  }

  Future<void> _openResult(AppSearchResult result) async {
    switch (result.type) {
      case AppSearchResultType.prayer:
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) =>
                PrayerCatalogDetailScreen(entry: result.prayerEntry!),
          ),
        );
      case AppSearchResultType.quote:
        showCupertinoModalPopup(
          context: context,
          builder: (context) => _QuoteDetailSheet(result: result),
        );
    }
  }
}

class _QuoteDetailSheet extends StatelessWidget {
  const _QuoteDetailSheet({required this.result});
  final AppSearchResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        IaculaSpacing.lg,
        IaculaSpacing.lg,
        IaculaSpacing.lg,
        IaculaSpacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.separator,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: IaculaSpacing.lg),
          Text(
            result.title,
            style: context.textStyles.secondary.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.colors.primaryButton,
            ),
          ),
          const SizedBox(height: IaculaSpacing.md),
          Text(
            '"${result.quoteText ?? result.snippet}"',
            textAlign: TextAlign.center,
            style: context.textStyles.cardTitle.copyWith(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: IaculaSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryState extends StatelessWidget {
  const _DiscoveryState({
    required this.recentQueries,
    required this.suggestions,
    required this.onSuggestionPressed,
  });

  final List<String> recentQueries;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const IaculaEmptyState(
          title: 'Encontre algo para este momento',
          message:
              'Busque por tema, santo, título ou use uma sugestão para começar sem pensar muito.',
        ),
        const SizedBox(height: IaculaSpacing.lg),
        Text('Sugestões para buscar', style: context.textStyles.cardTitle),
        const SizedBox(height: IaculaSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions
              .map(
                (suggestion) => _SearchChip(
                  label: suggestion,
                  onTap: () => onSuggestionPressed(suggestion),
                ),
              )
              .toList(growable: false),
        ),
        if (recentQueries.isNotEmpty) ...[
          const SizedBox(height: IaculaSpacing.lg),
          Text('Buscas recentes', style: context.textStyles.cardTitle),
          const SizedBox(height: IaculaSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentQueries
                .map(
                  (query) => _SearchChip(
                    label: query,
                    onTap: () => onSuggestionPressed(query),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ],
    );
  }
}

class _SearchChip extends StatelessWidget {
  const _SearchChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(
        horizontal: IaculaSpacing.md,
        vertical: IaculaSpacing.sm,
      ),
      color: context.colors.card,
      borderRadius: BorderRadius.circular(IaculaRadius.small),
      onPressed: onTap,
      child: Text(label, style: context.textStyles.secondary),
    );
  }
}

class _FilterControl extends StatelessWidget {
  const _FilterControl({
    required this.selectedFilter,
    required this.onChanged,
  });

  final _SearchFilter selectedFilter;
  final ValueChanged<_SearchFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<_SearchFilter>(
        groupValue: selectedFilter,
        children: const {
          _SearchFilter.all: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('Todos'),
          ),
          _SearchFilter.prayers: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('Orações'),
          ),
          _SearchFilter.quotes: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('Citações'),
          ),
          _SearchFilter.readings: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('Leituras'),
          ),
        },
        onValueChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.title,
    required this.results,
    required this.onTap,
    required this.query,
    required this.showSearchLabel,
  });

  final String title;
  final List<AppSearchResult> results;
  final ValueChanged<AppSearchResult> onTap;
  final String query;
  final bool showSearchLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSearchLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Resultados para "$query"',
              style: context.textStyles.secondary,
            ),
          ),
        Row(
          children: [
            Expanded(
              child: Text(
                '$title (${results.length})',
                style: context.textStyles.cardTitle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...results.map(
          (result) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ResultCard(result: result, onTap: () => onTap(result)),
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.onTap});
  final AppSearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: IaculaSoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.subtitle, style: context.textStyles.secondary),
            const SizedBox(height: 4),
            Text(
              result.title,
              style: context.textStyles.cardTitle,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 6),
            Text(
              result.snippet,
              style: context.textStyles.secondary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
