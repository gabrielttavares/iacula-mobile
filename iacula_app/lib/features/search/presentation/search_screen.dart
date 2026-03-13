import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../leituras/presentation/pages/book_reader_page.dart';
import '../../meditation/presentation/meditation_reader_screen.dart';
import '../../prayers/presentation/prayer_catalog_detail_screen.dart';
import '../application/app_search_service.dart';

const List<String> _searchSuggestions = [
  'recomeçar',
  'exame',
  'silêncio',
  'confiança',
];

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
  Timer? _debounce;

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
    final groupedResults = _groupResults(_results);
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
                placeholder: 'Busque por oração, Meditação, leitura ou citação',
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
                      itemCount: groupedResults.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final section = groupedResults[i];
                        return _ResultSection(
                          title: section.$1,
                          results: section.$2,
                          onTap: _openResult,
                          showSearchLabel: i == 0,
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

  Future<void> _openResult(AppSearchResult result) async {
    switch (result.type) {
      case AppSearchResultType.prayer:
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) =>
                PrayerCatalogDetailScreen(entry: result.prayerEntry!),
          ),
        );
      case AppSearchResultType.meditation:
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) =>
                MeditationReaderScreen(item: result.meditationItem!),
          ),
        );
      case AppSearchResultType.reading:
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => BookReaderPage(bookId: result.readingBook!.id),
          ),
        );
      case AppSearchResultType.quote:
        await IaculaModal.showAlert(
          context: context,
          title: result.title,
          message: result.snippet,
          actionLabel: 'Fechar',
        );
    }
  }
}

class _DiscoveryState extends StatelessWidget {
  const _DiscoveryState({
    required this.recentQueries,
    required this.onSuggestionPressed,
  });

  final List<String> recentQueries;
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
        Text('Sugestões para começar', style: context.textStyles.cardTitle),
        const SizedBox(height: IaculaSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _searchSuggestions
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
    final countLabel = results.length == 1
        ? '1 resultado'
        : '${results.length} resultados';
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
            Expanded(child: Text(title, style: context.textStyles.cardTitle)),
            Text(countLabel, style: context.textStyles.secondary),
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
