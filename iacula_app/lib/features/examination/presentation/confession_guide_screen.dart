// lib/features/examination/presentation/confession_guide_screen.dart

import 'package:flutter/cupertino.dart';

import '../../../core/theme/cupertino_tokens.dart';

class ConfessionGuideScreen extends StatelessWidget {
  const ConfessionGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: context.colors.background,
            border: null,
            largeTitle: const Text('Como se confessar'),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              24, 12, 24,
              28 + MediaQuery.paddingOf(context).bottom,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionTitle(context, 'Preparação para uma boa confissão'),
                const SizedBox(height: 16),
                _subheading(context, '1. Orações para infundir na alma o arrependimento necessário para a confissão'),
                const SizedBox(height: 12),
                _prayerTitle(context, 'a. Vinde, Espírito Santo'),
                const SizedBox(height: 8),
                _prayerBody(context,
                  'Vinde, Espírito Santo, e enchei os corações dos vossos fiéis, '
                  'e acendei neles o fogo do vosso amor.\n\n'
                  'Enviai, Senhor o vosso Espírito, e tudo será Criado, '
                  'e renovareis a face da terra.\n\n'
                  'Ó Deus, que instruístes os vossos fiéis, com a luz do Espírito Santo, '
                  'fazei que apreciemos retamente todas as coisas, e gozemos sempre da sua '
                  'consolação, por Cristo, Senhor nosso, Amém.',
                ),
                const SizedBox(height: 20),
                _prayerTitle(context, 'b. Pai Nosso, Ave Maria e Glória'),
                const SizedBox(height: 8),
                _prayerBody(context,
                  'Pai nosso, que estais no céu, santificado seja o Vosso Nome; venha a nós o '
                  'Vosso Reino, seja feita a Vossa Vontade, assim na terra como no céu. O pão '
                  'nosso de cada dia nos dai hoje, perdoai-nos as nossas ofensas, assim como '
                  'nós perdoamos a quem nos têm ofendido, e não nos deixeis cair em tentação, '
                  'mas livrai-nos do mal, Amém.\n\n'
                  'Ave, Maria, Cheia de Graça! O Senhor é contigo, bendita és tu entre as '
                  'mulheres e bendito é o fruto do teu ventre, Jesus! Santa Maria, mãe de Deus, '
                  'roga por nós pecadores, agora e na hora de nossa morte, Amém.\n\n'
                  'Glória ao Pai, ao Filho, e ao Espírito Santo, como era no princípio, agora '
                  'e sempre, Amém.\n\n'
                  'Ó, meu Jesus, livrai-nos do fogo do inferno, levai as almas todas para o '
                  'céu, principalmente as que mais precisarem!',
                ),
                const SizedBox(height: 20),
                _prayerTitle(context, 'c. Salmo 50 — Miserere'),
                const SizedBox(height: 4),
                _prayerSubtitle(context, '(que quer dizer "tem piedade", primeira palavra do Salmo)'),
                const SizedBox(height: 8),
                _prayerBody(context,
                  'Tende piedade de mim, ó Deus, segundo a vossa bondade, e conforme a '
                  'imensidade de vossa misericórdia, apagai a minha iniqüidade.\n\n'
                  'Lavai-me totalmente de minha falta, e purificai-me do meu pecado.\n\n'
                  'Eu reconheço a minha iniqüidade, diante de vós está sempre o meu pecado.\n\n'
                  'Só contra vós pequei, o que é mau fiz diante de vós. Vossa sentença assim se '
                  'manifesta justa, e reto o vosso julgamento.\n\n'
                  'Eis que nasci na culpa, minha mãe concebeu-me no pecado.\n\n'
                  'Não obstante, amas a sinceridade de coração; infunde-me, pois, a sabedoria no '
                  'mais íntimo de mim.\n\n'
                  'Aspergi-me com um ramo e ficarei puro; lavai-me e me tornarei mais branco do '
                  'que a neve.\n\n'
                  'Fazei-me ouvir uma palavra de gozo e de alegria, para que exultem os ossos '
                  'que triturastes.\n\n'
                  'Dos meus pecados desviai os olhos, e minhas culpas todas apagai.\n\n'
                  'Ó meu Deus, criai em mim um coração puro, e renovai-me o espírito de firmeza.\n\n'
                  'De vossa face não me rejeiteis, e nem me priveis de vosso Santo Espírito.\n\n'
                  'Restituí-me a alegria da salvação, e sustentai-me com uma vontade generosa.\n\n'
                  'Então, aos maus ensinarei vossos caminhos, e voltarão a vós os pecadores.\n\n'
                  'Deus, ó Deus, livrai-me da pena deste sangue derramado; E a vossa misericórdia '
                  'a minha língua exaltará.\n\n'
                  'Senhor, abri meus lábios, a fim de que minha boca anuncie os vossos louvores.\n\n'
                  'Vós não vos aplacais com sacrifícios rituais; e se eu vos oferecesse um '
                  'sacrifício vós não aceitaríeis;\n\n'
                  'Meu sacrifício, ó Senhor, é um espírito contrito; um coração arrependido e '
                  'humilhado, ó Deus, não haveis de desprezar.\n\n'
                  'Senhor, pela vossa bondade, tratai Sião com benevolência, reconstruí os muros '
                  'de Jerusalém!\n\n'
                  'Então aceitareis os sacrifícios prescritos, as oferendas e os holocaustos; '
                  'então, sobre o vosso altar vítima vos serão oferecidas.',
                ),
                const SizedBox(height: 20),
                _prayerTitle(context, 'd. Salmo 129 — De Profundis'),
                const SizedBox(height: 4),
                _prayerSubtitle(context, '(que quer dizer "do fundo", como começa o Salmo)'),
                const SizedBox(height: 8),
                _prayerBody(context,
                  'Do fundo do abismo, clamo a vós, Senhor!\n\n'
                  'Senhor, ouvi minha oração; que vossos ouvidos estejam atentos à voz de '
                  'minha súplica.\n\n'
                  'Se levardes em conta nossos pecados, Senhor, quem poderá permanecer diante '
                  'de vós?\n\n'
                  'Mas em vós se encontra o perdão dos pecados, para que, reverentes, o '
                  'sirvamos.\n\n'
                  'Ponho a minha esperança no Senhor. Minha alma tem confiança em sua palavra.\n\n'
                  'Minha alma espera pelo Senhor, mais ansiosa do que os vigias esperando a '
                  'manhã;\n\n'
                  'Mais do que os vigias aguardam a manhã, Espere Israel pelo Senhor. Porque '
                  'junto dele se acha a misericórdia; Encontra-se nele copiosa redenção.\n\n'
                  'Ele mesmo há de remir Israel de todas as suas iniqüidades.',
                ),
                const SizedBox(height: 24),
                _subheading(context, '2. Condições para a boa confissão'),
                const SizedBox(height: 12),
                _prayerBody(context,
                  'O conhecimento dos próprios pecados, sem o necessário arrependimento, em vez '
                  'de diminuir, só aumenta a gravidade das nossas culpas. E arrepender-se sem '
                  'pedir perdão agrava ainda mais o erro. É necessário reconhecer que erramos, '
                  'arrepender-se dos erros, e pedir perdão por esses erros.',
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) =>
      Text(text, style: context.textStyles.sectionTitle);

  Widget _subheading(BuildContext context, String text) =>
      Text(text, style: context.textStyles.cardTitle.copyWith(fontSize: 17));

  Widget _prayerTitle(BuildContext context, String text) =>
      Text(text, style: context.textStyles.cardTitle.copyWith(fontSize: 16));

  Widget _prayerSubtitle(BuildContext context, String text) =>
      Text(text, style: context.textStyles.secondary.copyWith(
        fontSize: 13, fontStyle: FontStyle.italic,
      ));

  Widget _prayerBody(BuildContext context, String text) =>
      Text(text, style: context.textStyles.secondary.copyWith(
        fontSize: 15, height: 1.6,
      ));
}
