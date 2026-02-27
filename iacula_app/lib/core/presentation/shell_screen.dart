import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../features/premium/domain/entities/premium_feature.dart';
import '../../features/premium/presentation/premium_gate.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/meditation/presentation/meditation_screen.dart';
import '../../features/plan_of_life/presentation/plan_of_life_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  int _currentIndex = 0;
  final _tabController = CupertinoTabController();
  static const _premiumIndexes = <int>{1, 2};

  static const _screens = <Widget>[
    HomeScreen(),
    MeditationScreen(),
    PlanOfLifeScreen(),
    FavoritesScreen(),
    ProfileScreen(),
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
        activeColor: const Color(0xFF111111),
        inactiveColor: const Color(0xFF6E6E73),
        onTap: (index) async {
          if (_premiumIndexes.contains(index)) {
            final asyncStatus = ref.read(premiumStatusProvider);
            if (asyncStatus.hasValue && asyncStatus.value?.isPremium != true) {
              _tabController.index = _currentIndex;
              final feature = index == 1
                  ? PremiumFeature.meditation
                  : PremiumFeature.planOfLife;
              PremiumGate.showModal(context, feature: feature);
              return;
            }
          }

          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.play_circle),
            label: 'Meditação',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.check_mark_circled),
            label: 'Plano de vida',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bookmark),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Perfil',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(builder: (_) => _screens[index]);
      },
    );
  }
}
