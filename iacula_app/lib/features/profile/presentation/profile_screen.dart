import 'package:flutter/cupertino.dart';

import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../settings/presentation/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(IaculaSpacing.md),
          children: [
            const IaculaLargeTitle('Perfil'),
            const SizedBox(height: IaculaSpacing.lg),
            const Center(child: _Avatar()),
            const SizedBox(height: IaculaSpacing.xl),
            _Section(
              title: 'Conta',
              rows: const [
                _InfoRow(label: 'Nome', value: 'Pedro Gabriel'),
                _InfoRow(label: 'E-mail', value: 'pedro@iacula.app'),
                _InfoRow(label: 'Idioma', value: 'Português (Brasil)'),
              ],
            ),
            const SizedBox(height: IaculaSpacing.lg),
            _Section(
              title: 'Privacidade e segurança',
              rows: const [
                _InfoRow(label: 'Conta', value: 'Conectada'),
                _InfoRow(label: 'Backup', value: 'Sincronização ativa'),
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
}

class _Avatar extends StatelessWidget {
  const _Avatar();

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
            child: const Text(
              'PG',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: IaculaColors.textPrimary,
              ),
            ),
          ),
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
  const _Section({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IaculaSectionHeader(
          title: title,
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () {},
            child: const Text(
              'Editar',
              style: TextStyle(
                color: IaculaColors.primaryButton,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
