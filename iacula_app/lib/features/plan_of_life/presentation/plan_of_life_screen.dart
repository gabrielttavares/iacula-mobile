import 'package:flutter/material.dart';
import 'widgets/plan_item_row.dart';

class PlanOfLifeScreen extends StatefulWidget {
  const PlanOfLifeScreen({super.key});

  @override
  State<PlanOfLifeScreen> createState() => _PlanOfLifeScreenState();
}

class _PlanOfLifeScreenState extends State<PlanOfLifeScreen> {
  // Mocked state: List of Map with title and isCompleted
  final List<Map<String, dynamic>> _planItems = [
    {'title': 'Oferecimento de obras', 'isCompleted': false},
    {'title': 'Leitura do Santo Evangelho', 'isCompleted': false},
    {'title': 'Leitura espiritual', 'isCompleted': false},
    {'title': 'Angelus (Anjo do Senhor)', 'isCompleted': false},
    {'title': 'Oração mental (ou meditação)', 'isCompleted': false},
    {'title': 'Visita ao Santíssimo', 'isCompleted': false},
    {'title': 'Terço', 'isCompleted': false},
    {'title': 'Santa Missa', 'isCompleted': false},
    {'title': '3 Ave-Marias antes de deitar', 'isCompleted': false},
    {'title': 'Exame de consciência', 'isCompleted': false},
  ];

  final List<Map<String, String>> _mockDates = [
    {'day': 'Ter', 'date': '04'},
    {'day': 'Qua', 'date': '05'},
    {'day': 'Qui', 'date': '06'},
    {'day': 'Sex', 'date': '07'},
    {'day': 'Sáb', 'date': '08'},
    {'day': 'Dom', 'date': '09'},
    {'day': 'Seg', 'date': '10'},
  ];

  int _selectedDateIndex = 1;

  void _toggleItem(int index, bool newValue) {
    setState(() {
      _planItems[index]['isCompleted'] = newValue;
    });
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 24.0, bottom: 8.0, right: 20.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Plano de Vida',
          style: theme.textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Horizontal Date Picker (Mocked)
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _mockDates.length,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, index) {
                  final date = _mockDates[index];
                  final isActive = index == _selectedDateIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDateIndex = index;
                      });
                    },
                    child: Container(
                      width: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: isActive ? colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            date['day']!,
                            style: TextStyle(
                              fontSize: 13,
                              color: isActive ? colorScheme.onPrimary : theme.disabledColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date['date']!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              color: isActive ? colorScheme.onPrimary : colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _planItems.length + 3, // 3 headers: Manhã, Tarde, Noite
                padding: const EdgeInsets.only(bottom: 32.0, top: 8.0),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildSectionHeader('Manhã', Icons.wb_sunny_outlined, theme);
                  }
                  if (index == 4) {
                    return _buildSectionHeader('Tarde', Icons.cloud_outlined, theme);
                  }
                  if (index == 10) {
                    return _buildSectionHeader('Noite', Icons.nights_stay_outlined, theme);
                  }

                  // Adjust index mapping based on headers
                  int itemIndex = index - 1; // offset by 1 for first header
                  if (index > 4) itemIndex -= 1; // offset by 2 for second header
                  if (index > 10) itemIndex -= 1; // offset by 3 for third header

                  final item = _planItems[itemIndex];
                  return PlanItemRow(
                    title: item['title'] as String,
                    isCompleted: item['isCompleted'] as bool,
                    onToggle: (bool newValue) => _toggleItem(itemIndex, newValue),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
