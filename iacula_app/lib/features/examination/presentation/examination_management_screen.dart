import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_input.dart';
import '../../../core/presentation/widgets/iacula_spring_button.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/examination_reflection_item.dart';

class ExaminationManagementScreen extends ConsumerStatefulWidget {
  const ExaminationManagementScreen({super.key});

  @override
  ConsumerState<ExaminationManagementScreen> createState() =>
      _ExaminationManagementScreenState();
}

class _ExaminationManagementScreenState
    extends ConsumerState<ExaminationManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref
          .read(examinationReflectionRepositoryProvider)
          .seedDefaultsIfEmpty(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(examinationReflectionItemsProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Gerenciar perguntas'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => const _ExaminationReflectionEditorScreen(),
            ),
          ),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: itemsAsync.when(
          data: (items) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _ManagementItemCard(item: items[index]),
          ),
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              'Não foi possível carregar as perguntas.',
              style: context.textStyles.secondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ManagementItemCard extends ConsumerWidget {
  const _ManagementItemCard({required this.item});

  final ExaminationReflectionItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: IaculaShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) =>
                        _ExaminationReflectionEditorScreen(existingItem: item),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.sectionTitle,
                      style: context.textStyles.cardTitle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.text,
                      style: context.textStyles.secondary.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => ref
                  .read(examinationReflectionRepositoryProvider)
                  .deleteItem(item.id),
              child: Icon(CupertinoIcons.delete, color: context.colors.error),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExaminationReflectionEditorScreen extends ConsumerStatefulWidget {
  const _ExaminationReflectionEditorScreen({this.existingItem});

  final ExaminationReflectionItem? existingItem;

  @override
  ConsumerState<_ExaminationReflectionEditorScreen> createState() =>
      _ExaminationReflectionEditorScreenState();
}

class _ExaminationReflectionEditorScreenState
    extends ConsumerState<_ExaminationReflectionEditorScreen> {
  late final TextEditingController _sectionController;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _sectionController = TextEditingController(
      text: widget.existingItem?.sectionTitle ?? '',
    );
    _textController = TextEditingController(
      text: widget.existingItem?.text ?? '',
    );
  }

  @override
  void dispose() {
    _sectionController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.existingItem == null ? 'Nova pergunta' : 'Editar pergunta',
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Título da seção', style: context.textStyles.secondary),
              const SizedBox(height: 8),
              IaculaTextInput(controller: _sectionController),
              const SizedBox(height: 16),
              Text('Texto', style: context.textStyles.secondary),
              const SizedBox(height: 8),
              IaculaTextInput(
                controller: _textController,
                maxLines: 5,
                minLines: 5,
                textCapitalization: TextCapitalization.sentences,
              ),
              const Spacer(),
              IaculaSpringButton(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: context.colors.primaryButton,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Salvar',
                    style: context.textStyles.cardTitle.copyWith(
                      color: context.colors.background,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final sectionTitle = _sectionController.text.trim();
    final text = _textController.text.trim();
    if (sectionTitle.isEmpty || text.isEmpty) return;

    final repository = ref.read(examinationReflectionRepositoryProvider);
    final existing = widget.existingItem;

    if (existing == null) {
      await repository.createItem(sectionTitle: sectionTitle, text: text);
    } else {
      await repository.updateItem(
        existing.copyWith(sectionTitle: sectionTitle, text: text),
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
