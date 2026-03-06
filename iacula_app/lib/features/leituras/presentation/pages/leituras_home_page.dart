import 'package:flutter/cupertino.dart';

import 'author_list_page.dart';

class LeiturasHomePage extends StatelessWidget {
  const LeiturasHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthorListPage(
      navigationTitle: 'Leituras',
      showLeiturasIntro: true,
    );
  }
}
