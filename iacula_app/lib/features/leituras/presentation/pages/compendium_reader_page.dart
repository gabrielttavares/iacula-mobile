import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/presentation/design/iacula_modal.dart';
import '../../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../../meditation/presentation/widgets/meditation_web_content.dart';

const compendiumCatechismUrl =
    'https://odnmedia.s3.amazonaws.com/files/Catecismo%20da%20Igreja%20Catolica_%20C20210324-114223.pdf';

typedef CompendiumContentBuilder =
    Widget Function(BuildContext context, String url, String title);

class CompendiumReaderPage extends StatelessWidget {
  const CompendiumReaderPage({super.key, this.contentBuilder});

  final CompendiumContentBuilder? contentBuilder;

  static const title = 'Compêndio do Catecismo da Igreja Católica';

  @override
  Widget build(BuildContext context) {
    final buildContent =
        contentBuilder ??
        (context, url, title) => MeditationWebContent(url: url, title: title);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Compêndio'),
        backgroundColor: context.colors.background,
        border: null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            IaculaSpacing.md,
            IaculaSpacing.md,
            IaculaSpacing.md,
            IaculaSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: context.textStyles.sectionTitle),
              const SizedBox(height: IaculaSpacing.sm),
              Text(
                'Leia o Compêndio sem sair do app. Se o PDF não carregar, abra no navegador.',
                style: context.textStyles.secondary,
              ),
              const SizedBox(height: IaculaSpacing.md),
              Expanded(
                child: buildContent(context, compendiumCatechismUrl, title),
              ),
              const SizedBox(height: IaculaSpacing.md),
              IaculaSecondaryPillButton(
                label: 'Abrir no navegador',
                onPressed: () => _openExternal(context),
              ),
              SizedBox(
                height: MediaQuery.paddingOf(context).bottom + IaculaSpacing.md,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openExternal(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse(compendiumCatechismUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      await IaculaModal.showOpenLinkAlert(context);
    }
  }
}
