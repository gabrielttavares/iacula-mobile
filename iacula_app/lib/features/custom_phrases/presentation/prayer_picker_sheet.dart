import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../prayers/domain/entities/prayer_catalog_entry.dart';

class PrayerPickerSheet extends ConsumerStatefulWidget {
  const PrayerPickerSheet({super.key});

  static Future<PrayerCatalogEntry?> show(BuildContext context) {
    return IaculaModal.showSheet<PrayerCatalogEntry>(
      context: context,
      maxHeightFraction: 0.85,
      builder: (_) => const PrayerPickerSheet(),
    );
  }

  @override
  ConsumerState<PrayerPickerSheet> createState() => _PrayerPickerSheetState();
}

class _PrayerPickerSheetState extends ConsumerState<PrayerPickerSheet> {
  List<PrayerCatalogEntry> _allEntries = const [];
  List<PrayerCatalogEntry> _filteredEntries = const [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrayers();
  }

  Future<void> _loadPrayers() async {
    final settings = await ref.read(getSettingsUseCaseProvider).call();
    final entries = await ref
        .read(getPrayerCatalogUseCaseProvider)
        .listAll(language: settings.language);
    if (!mounted) return;
    setState(() {
      _allEntries = entries;
      _filteredEntries = entries;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    final normalizedQuery = _normalize(query);
    setState(() {
      _searchQuery = query;
      if (normalizedQuery.isEmpty) {
        _filteredEntries = _allEntries;
      } else {
        _filteredEntries = _allEntries
            .where((entry) => _normalize(entry.title).contains(normalizedQuery))
            .toList();
      }
    });
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãä]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final groupedEntries = <String, List<PrayerCatalogEntry>>{};
    for (final entry in _filteredEntries) {
      final section = entry.sectionTitle.isNotEmpty
          ? entry.sectionTitle
          : 'Outras';
      groupedEntries.putIfAbsent(section, () => []).add(entry);
    }

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: context.colors.separator,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Selecionar Oração',
                  style: context.textStyles.sectionTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),
                CupertinoSearchTextField(
                  placeholder: 'Buscar oração...',
                  onChanged: _onSearchChanged,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : _filteredEntries.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhuma oração encontrada',
                          style: context.textStyles.secondary,
                        ),
                      )
                    : _searchQuery.isNotEmpty
                        ? _buildFlatList()
                        : _buildGroupedList(groupedEntries),
          ),
        ],
      ),
    );
  }

  Widget _buildFlatList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _filteredEntries.length,
      itemBuilder: (context, index) =>
          _PrayerTile(
            entry: _filteredEntries[index],
            onTap: () => Navigator.of(context).pop(_filteredEntries[index]),
          ),
    );
  }

  Widget _buildGroupedList(
    Map<String, List<PrayerCatalogEntry>> groupedEntries,
  ) {
    final sections = groupedEntries.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: sections.length,
      itemBuilder: (context, sectionIndex) {
        final sectionTitle = sections[sectionIndex];
        final entries = groupedEntries[sectionTitle]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                sectionTitle.toUpperCase(),
                style: context.textStyles.secondary.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (final entry in entries)
              _PrayerTile(
                entry: entry,
                onTap: () => Navigator.of(context).pop(entry),
              ),
          ],
        );
      },
    );
  }
}

class _PrayerTile extends StatelessWidget {
  const _PrayerTile({required this.entry, required this.onTap});

  final PrayerCatalogEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          entry.title,
          style: context.textStyles.cardTitle.copyWith(fontSize: 15),
        ),
      ),
    );
  }
}
