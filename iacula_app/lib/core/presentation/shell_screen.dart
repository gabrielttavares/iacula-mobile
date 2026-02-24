import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../features/premium/domain/entities/premium_feature.dart';
import '../../features/premium/presentation/premium_gate.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/meditation/presentation/meditation_screen.dart';
import '../../features/plan_of_life/presentation/plan_of_life_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  int _currentIndex = 0;
  static const _premiumIndexes = <int>{1, 2};

  final List<Widget> _screens = const [
    HomeScreen(),
    MeditationScreen(),
    PlanOfLifeScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
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
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Meditação',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Plano de Vida',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
