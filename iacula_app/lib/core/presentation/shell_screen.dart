import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/bible/presentation/bible_books_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../theme/cupertino_tokens.dart';

class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  int _currentIndex = 0;
  final _tabController = CupertinoTabController();
  late final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    _screens.length,
    (_) => GlobalKey<NavigatorState>(),
  );

  static const _screens = <Widget>[
    HomeScreen(),
    BibleBooksScreen(),
    FavoritesScreen(),
    MoreScreen(),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        activeColor: context.colors.primaryButton,
        inactiveColor: context.colors.textSecondary,
        onTap: (index) async {
          if (index == _currentIndex) {
            final tabNavigator = _navigatorKeys[index].currentState;
            if (tabNavigator != null && tabNavigator.canPop()) {
              tabNavigator.popUntil((route) => route.isFirst);
              return;
            }

            final rootNavigator = Navigator.of(context, rootNavigator: true);
            if (rootNavigator.canPop()) {
              rootNavigator.popUntil((route) => route.isFirst);
            }
            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: SizedBox(width: 30, child: Icon(CupertinoIcons.house)),
            ),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: SizedBox(width: 30, child: Icon(CupertinoIcons.book)),
            ),
            label: 'Bíblia',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: SizedBox(width: 30, child: Icon(CupertinoIcons.bookmark)),
            ),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: SizedBox(
                width: 30,
                child: Icon(CupertinoIcons.ellipsis),
              ),
            ),
            label: 'Mais',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          navigatorKey: _navigatorKeys[index],
          builder: (_) => _screens[index],
        );
      },
    );
  }
}
