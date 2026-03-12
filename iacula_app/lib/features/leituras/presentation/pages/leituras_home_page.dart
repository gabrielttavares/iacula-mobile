import 'package:flutter/cupertino.dart';

import 'author_list_page.dart';
import 'compendium_reader_page.dart';

class LeiturasHomePage extends StatelessWidget {
  const LeiturasHomePage({super.key, this.compendiumContentBuilder});

  final CompendiumContentBuilder? compendiumContentBuilder;

  @override
  Widget build(BuildContext context) {
    return AuthorListPage(
      navigationTitle: 'Leituras',
      showLeiturasIntro: true,
      compendiumContentBuilder: compendiumContentBuilder,
    );
  }
}
