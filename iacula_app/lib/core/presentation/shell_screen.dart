import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../features/premium/domain/entities/premium_feature.dart';
import '../../features/premium/presentation/premium_gate.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/meditation/presentation/meditation_screen.dart';
import '../../features/plan_of_life/presentation/plan_of_life_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  int _currentIndex = 0;
  static const _premiumIndexes = <int>{1, 2};

  static const _screens = <Widget>[
    HomeScreen(),
    MeditationScreen(),
    PlanOfLifeScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        activeColor: const Color(0xFF111111),
        inactiveColor: const Color(0xFF6E6E73),
        onTap: (index) async {
          if (_premiumIndexes.contains(index)) {
            final status = ref.read(premiumStatusProvider).valueOrNull;
            if (status?.isPremium != true) {
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
