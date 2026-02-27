import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../settings/presentation/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final isConnected = user != null;
    final localName = ref.watch(localDisplayNameProvider).valueOrNull;
    final name = user?.displayName ?? localName ?? 'Sem conta';
    final email = user?.email ?? '\u2014';

    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(IaculaSpacing.md),
          children: [
            const IaculaLargeTitle('Perfil'),
            const SizedBox(height: IaculaSpacing.lg),
            Center(child: _Avatar(name: name, showEditBadge: isConnected)),
            const SizedBox(height: IaculaSpacing.xl),
            _Section(
              title: 'Conta',
              onEdit: isConnected
                  ? () => _showProviderNameDialog(context)
                  : () => _showLocalNameDialog(context, ref, localName),
              rows: [
                _InfoRow(label: 'Nome', value: name),
                _InfoRow(label: 'E-mail', value: email),
                const _InfoRow(label: 'Idioma', value: 'Português (Brasil)'),
              ],
            ),
            const SizedBox(height: IaculaSpacing.lg),
            _Section(
              title: 'Privacidade e segurança',
              rows: [
                _InfoRow(label: 'Conta', value: isConnected ? 'Conectada' : 'Não conectada'),
                _InfoRow(label: 'Backup', value: isConnected ? 'Sincronização ativada' : 'Apenas local'),
              ],
            ),
            const SizedBox(height: IaculaSpacing.lg),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => const SettingsScreen(),
                    title: 'Configurações',
                  ),
                );
              },
              child: const IaculaSoftCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Configurações', style: IaculaText.cardTitle),
                    ),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 18,
                      color: IaculaColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showProviderNameDialog(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Editar nome'),
        content: const Column(
          children: [
            SizedBox(height: 8),
            Text(
              'Seu nome é gerenciado pelo provedor de login (Google, Microsoft ou Apple). '
              'Para alterá-lo, atualize seu perfil no provedor.',
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showLocalNameDialog(
    BuildContext context,
    WidgetRef ref,
    String? currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Editar nome'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Seu nome',
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) {
                Navigator.of(ctx).pop();
                return;
              }
              final settings =
                  await ref.read(getSettingsUseCaseProvider).call();
              await ref
                  .read(updateSettingsUseCaseProvider)
                  .call(settings.copyWith(displayName: newName));
              ref.invalidate(localDisplayNameProvider);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.showEditBadge});

  final String name;
  final bool showEditBadge;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoColors.white,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: IaculaColors.textPrimary,
              ),
            ),
          ),
          if (showEditBadge)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: IaculaColors.primaryButton,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.pencil,
                  size: 16,
                  color: CupertinoColors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows, this.onEdit});

  final String title;
  final List<Widget> rows;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IaculaSectionHeader(
          title: title,
          trailing: onEdit != null
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: onEdit,
                  child: const Text(
                    'Editar',
                    style: TextStyle(
                      color: IaculaColors.primaryButton,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: IaculaSpacing.sm),
        IaculaSoftCard(
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i != rows.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0x14000000)),
                      child: SizedBox(height: 1, width: double.infinity),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: IaculaText.secondary),
        const SizedBox(height: 4),
        Text(value, style: IaculaText.cardTitle),
      ],
    );
  }
}
