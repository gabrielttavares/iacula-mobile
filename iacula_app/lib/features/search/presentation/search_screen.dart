import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../liturgical/domain/liturgical_season.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';
  List<_SearchResult> _results = [];
  bool _loading = false;

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _results = [];
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
    final quoteRepo = ref.read(quoteContentRepositoryProvider);
    final lowerQuery = query.toLowerCase();

    // Search quotes across all seasons
    final results = <_SearchResult>[];
    for (final season in LiturgicalSeason.values) {
      try {
        final quotes = await quoteRepo.loadQuotes(
          language: settings.language,
          season: season,
        );
        for (final entry in quotes.entries) {
          for (final text in entry.value.quotes) {
            if (text.toLowerCase().contains(lowerQuery)) {
              results.add(
                _SearchResult(
                  text: text,
                  category: entry.value.theme,
                  type: 'Citação',
                ),
              );
            }
          }
        }
      } catch (_) {
        // Season may not have quotes, skip
      }
    }

    setState(() {
      _results = results.take(50).toList(); // Limit to 50 results
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      navigationBar: const CupertinoNavigationBar(middle: Text('Pesquisar')),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(IaculaSpacing.md),
              child: CupertinoSearchTextField(
                placeholder: 'Pesquisar citações...',
                onChanged: _search,
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _query.trim().length < 2
                  ? const Center(
                      child: IaculaEmptyState(
                        title: 'Pesquisar',
                        message: 'Pesquise por citações dos santos.',
                      ),
                    )
                  : _results.isEmpty
                  ? Center(
                      child: IaculaEmptyState(
                        title: 'Sem resultados',
                        message: 'Nenhum resultado para "$_query".',
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: IaculaSpacing.md,
                      ),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _ResultCard(result: _results[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResult {
  const _SearchResult({
    required this.text,
    required this.category,
    required this.type,
  });
  final String text;
  final String category;
  final String type;
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final _SearchResult result;

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(result.category, style: IaculaText.secondary),
          const SizedBox(height: 4),
          Text(result.text, style: IaculaText.cardTitle),
        ],
      ),
    );
  }
}
