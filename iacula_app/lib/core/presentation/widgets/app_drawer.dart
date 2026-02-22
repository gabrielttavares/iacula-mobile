import 'package:flutter/material.dart';
import '../../../features/meditation/presentation/meditation_screen.dart';
import '../../../features/plan_of_life/presentation/plan_of_life_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E1A17), // Dark, warm background
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              'I A C U L A',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD6BA8E),
                  ),
            ),
            const SizedBox(height: 16),
            Divider(
              color: const Color(0xFF837562).withValues(alpha: 0.3),
              indent: 24,
              endIndent: 24,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _DrawerItem(
                    icon: Icons.home_rounded,
                    title: 'Início',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Sobre/Espiritualidade',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.church_rounded,
                    title: 'Devoções & Orações',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.menu_book_rounded,
                    title: 'Meditação Diária',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MeditationScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.checklist_rounded,
                    title: 'Plano de Vida',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PlanOfLifeScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFFD6BA8E),
        size: 24,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFF8EFE1),
              fontWeight: FontWeight.w500,
            ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      hoverColor: const Color(0xFF3D3125).withValues(alpha: 0.5),
      splashColor: const Color(0xFF3D3125),
      onTap: onTap,
    );
  }
}
