import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../auth/presentation/auth_action_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final isConnected = user != null;
    
    // If not connected, show login options
    if (!isConnected) {
      final authRepo = ref.read(authRepositoryProvider);
      return CupertinoPageScaffold(
        backgroundColor: context.colors.background,
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Perfil'),
          backgroundColor: context.colors.background,
          border: null,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(IaculaSpacing.md),
            child: Align(
              alignment: Alignment.topCenter,
              child: AuthActionSheet(
                title: 'Sincronização entre dispositivos',
                subtitle:
                    'Faça login para manter seus dados espirituais sincronizados entre dispositivos. A sincronização acontece automaticamente.',
                onGoogle: () => authRepo.signInWithGoogle(),
                onMicrosoft: () => authRepo.signInWithMicrosoft(),
                onApple: () => authRepo.signInWithApple(),
                onSignOut: () => authRepo.signOut(),
              ),
            ),
          ),
        ),
      );
    }

    final localName = ref.watch(localDisplayNameProvider).valueOrNull;
    final name = user.displayName ?? localName ?? 'Sem nome';
    final email = user.email;

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Perfil'),
            backgroundColor: context.colors.background,
            border: null,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(IaculaSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Center(
                  child: _Avatar(name: name, onTap: () => _showAvatarActions(context)),
                ),
                const SizedBox(height: IaculaSpacing.xl),
                _Section(
                  title: 'Dados da conta',
                  onEdit: () => _showProviderNameDialog(context),
                  rows: [
                    _InfoRow(label: 'Nome', value: name),
                    _InfoRow(label: 'E-mail', value: email),
                    const _InfoRow(label: 'Data de nascimento', value: '\u2014'),
                    const _InfoRow(label: 'Telefone', value: '\u2014'),
                    const _InfoRow(label: 'Gênero', value: '\u2014'),
                  ],
                ),
                const SizedBox(height: IaculaSpacing.lg),
                _Section(
                  title: 'Segurança',
                  rows: [
                    _ActionRow(
                      label: 'Senha',
                      icon: CupertinoIcons.lock,
                      onTap: () => _showNotImplemented(context),
                    ),
                    _ActionRow(
                      label: 'Sair da conta',
                      icon: CupertinoIcons.square_arrow_right,
                      isDestructive: true,
                      onTap: () => ref.read(authRepositoryProvider).signOut(),
                    ),
                    _ActionRow(
                      label: 'Deletar conta',
                      icon: CupertinoIcons.trash,
                      isDestructive: true,
                      onTap: () => _showDeleteConfirmation(context),
                    ),
                  ],
                ),
              ]),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + IaculaSpacing.md,
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarActions(BuildContext context) {
    HapticFeedback.lightImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Foto de perfil'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tirar foto'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Escolher da galeria'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  void _showProviderNameDialog(BuildContext context) {
    IaculaModal.showAlert(
      context: context,
      title: 'Editar nome',
      message:
          'Seu nome é gerenciado pelo provedor de login (Google, Microsoft ou Apple). '
          'Para alterá-lo, atualize seu perfil no provedor.',
    );
  }

  void _showNotImplemented(BuildContext context) {
    IaculaModal.showAlert(
      context: context,
      title: 'Em breve',
      message: 'Esta funcionalidade estará disponível em uma atualização futura.',
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Deletar conta'),
        content: const Text(
          'Tem certeza que deseja deletar sua conta? Esta ação é irreversível e todos os seus dados serão perdidos.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              // Implementation would go here
              Navigator.pop(context);
              _showNotImplemented(context);
            },
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 104,
        height: 104,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.card,
              ),
              alignment: Alignment.center,
              child: Text(
                _initials,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.colors.primaryButton,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.camera_fill,
                  size: 16,
                  color: context.colors.background,
                ),
              ),
            ),
          ],
        ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: context.textStyles.sectionTitle.copyWith(fontSize: 20),
            ),
            if (onEdit != null)
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: onEdit,
                child: Text(
                  'Editar',
                  style: TextStyle(
                    color: context.colors.primaryButton,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: IaculaSpacing.sm),
        IaculaSoftCard(
          padding: const EdgeInsets.all(IaculaSpacing.md),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i != rows.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: context.colors.separator),
                      child: const SizedBox(height: 1, width: double.infinity),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.textStyles.secondary),
        Text(value, style: context.textStyles.cardTitle.copyWith(fontSize: 15)),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDestructive ? context.colors.error : context.colors.primaryButton,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: context.textStyles.cardTitle.copyWith(
                fontSize: 15,
                color: isDestructive ? context.colors.error : null,
              ),
            ),
          ),
          Icon(
            CupertinoIcons.chevron_right,
            size: 16,
            color: context.colors.textSecondary,
          ),
        ],
      ),
    );
  }
}
