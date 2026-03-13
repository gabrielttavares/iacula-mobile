import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../features/premium/domain/entities/premium_feature.dart';
import '../../features/premium/presentation/premium_gate.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/meditation/presentation/meditation_screen.dart';
import '../../features/plan_of_life/presentation/plan_of_life_screen.dart';
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
  static const _premiumIndexes = <int>{2};
  late final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    _screens.length,
    (_) => GlobalKey<NavigatorState>(),
  );

  static const _screens = <Widget>[
    HomeScreen(),
    MeditationScreen(),
    PlanOfLifeScreen(),
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
          if (_premiumIndexes.contains(index)) {
            final asyncStatus = ref.read(premiumStatusProvider);
            final isPremium = asyncStatus.valueOrNull?.isPremium ?? false;
            if (!isPremium) {
              _tabController.index = _currentIndex;
              final feature = PremiumFeature.planOfLife;
              PremiumGate.showModal(context, feature: feature);
              return;
            }
          }

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
              child: SizedBox(
                width: 30,
                child: Icon(CupertinoIcons.house),
              ),
            ),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: SizedBox(
                width: 30,
                child: Icon(CupertinoIcons.book),
              ),
            ),
            label: 'Meditação',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: SizedBox(
                width: 30,
                child: Icon(CupertinoIcons.check_mark_circled),
              ),
            ),
            label: 'Plano',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: SizedBox(
                width: 30,
                child: Icon(CupertinoIcons.bookmark),
              ),
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
