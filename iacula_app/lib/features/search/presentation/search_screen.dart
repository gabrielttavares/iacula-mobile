import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../leituras/presentation/pages/book_reader_page.dart';
import '../../meditation/presentation/meditation_detail_screen.dart';
import '../../prayers/presentation/prayer_catalog_detail_screen.dart';
import '../application/app_search_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';
  List<AppSearchResult> _results = [];
  bool _loading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

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
    final results = await ref.read(appSearchServiceProvider).search(
          query: query,
          language: settings.language,
        );

    setState(() {
      _results = results;
      _loading = false;
    });
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      _search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: const CupertinoNavigationBar(middle: Text('Buscar')),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(IaculaSpacing.md),
              child: CupertinoSearchTextField(
                placeholder: 'Buscar orações, leituras e meditações',
                onChanged: _onQueryChanged,
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _query.trim().length < 2
                  ? const Center(
                      child: IaculaEmptyState(
                        title: 'Busque no app',
                        message:
                            'Procure por uma oração, meditação, leitura ou citação.',
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
                        bottom: MediaQuery.paddingOf(context).bottom +
                            IaculaSpacing.md,
                      ),
                      itemCount: _results.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) => _ResultCard(
                        result: _results[i],
                        onTap: () => _openResult(_results[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openResult(AppSearchResult result) async {
    switch (result.type) {
      case AppSearchResultType.prayer:
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => PrayerCatalogDetailScreen(
              entry: result.prayerEntry!,
            ),
          ),
        );
      case AppSearchResultType.meditation:
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => MeditationDetailScreen(
              item: result.meditationItem!,
            ),
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
