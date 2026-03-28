import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../infrastructure/app_store_review.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../../core/presentation/design/iacula_modal.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    final build = info.buildNumber.trim();
    if (build.isEmpty) {
      return info.version;
    }
    return '${info.version}+$build';
  } catch (_) {
    return '-';
  }
});

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Mais'),
            backgroundColor: context.colors.background,
            border: null,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(IaculaSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Perfil (navegação para ProfileScreen) — desativado temporariamente
                // _MoreItem(
                //   label: 'Perfil',
                //   icon: CupertinoIcons.person,
                //   onTap: () => _navigate(context, const ProfileScreen(), 'Perfil'),
                // ),
                // const SizedBox(height: IaculaSpacing.sm),
                _MoreItem(
                  label: 'Configurações',
                  icon: CupertinoIcons.settings,
                  onTap: () => _navigate(
                    context,
                    const SettingsScreen(),
                    'Configurações',
                  ),
                ),
                const SizedBox(height: IaculaSpacing.sm),
                _MoreItem(
                  label: 'Notificações',
                  icon: CupertinoIcons.bell,
                  onTap: () => _navigate(
                    context,
                    const NotificationsScreen(),
                    'Notificações',
                  ),
                ),
                const SizedBox(height: IaculaSpacing.lg),
                const IaculaSectionHeader(title: 'Suporte e Sobre'),
                const SizedBox(height: IaculaSpacing.sm),
                _MoreItem(
                  label: 'Sobre',
                  icon: CupertinoIcons.info,
                  onTap: () => _showAbout(context),
                ),
                const SizedBox(height: IaculaSpacing.sm),
                _MoreItem(
                  label: 'Reportar problema',
                  icon: CupertinoIcons.mail,
                  onTap: () => _reportProblem(),
                ),
                const SizedBox(height: IaculaSpacing.sm),
                _MoreItem(
                  label: 'Avaliar experiência',
                  icon: CupertinoIcons.star,
                  onTap: () => _rateApp(),
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

  void _navigate(BuildContext context, Widget screen, String title) {
    HapticFeedback.lightImpact();
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (_) => screen, title: title));
  }

  void _showAbout(BuildContext context) {
    HapticFeedback.lightImpact();
    IaculaModal.showSheet<void>(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final versionAsync = ref.watch(appVersionProvider);
          final versionLabel = versionAsync.when(
            data: (value) => 'Versão $value',
            loading: () => 'Versão ...',
            error: (e, _) => 'Versão -',
          );

          return Padding(
            padding: const EdgeInsets.all(IaculaSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sobre o Iacula', style: context.textStyles.cardTitle),
                const SizedBox(height: IaculaSpacing.md),
                Text(
                  'O Iacula foi pensado para ajudar você a manter viva a oração breve no meio das tarefas normais do dia.\n\n'
                  'Inspirado na espiritualidade do trabalho santificado, o app procura acompanhar você nos momentos certos.',
                  style: context.textStyles.secondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: IaculaSpacing.md),
                Text(
                  versionLabel,
                  style: context.textStyles.secondary.copyWith(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: IaculaSpacing.lg),
                CupertinoButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Fechar',
                    style: TextStyle(color: context.colors.primaryButton),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _reportProblem() async {
    HapticFeedback.lightImpact();
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'gabrielttav777@gmail.com',
      query: 'subject=Feedback Iacula',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  Future<void> _rateApp() async {
    HapticFeedback.lightImpact();
    await openAppStoreReview();
  }
}

class _MoreItem extends StatelessWidget {
  const _MoreItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IaculaSoftCard(
        padding: const EdgeInsets.symmetric(
          horizontal: IaculaSpacing.md,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: context.colors.primaryButton),
            const SizedBox(width: IaculaSpacing.md),
            Expanded(
              child: Text(
                label,
                style: context.textStyles.cardTitle.copyWith(fontSize: 16),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
