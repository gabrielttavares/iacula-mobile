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
    {'title': 'Exame de consciência (antes de deitar)', 'isCompleted': false},
  ];

  void _toggleItem(int index, bool newValue) {
    setState(() {
      _planItems[index]['isCompleted'] = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1A17), // Match the dark warm theme
      appBar: AppBar(
        title: Text(
          'Plano de Vida',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFFD6BA8E),
                fontWeight: FontWeight.w600,
              ),
        ),
        backgroundColor: const Color(0xFF1E1A17),
        iconTheme: const IconThemeData(color: Color(0xFFD6BA8E)),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Text(
                'Acompanhe e renove diariamente o seu compromisso de vida espiritual.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF837562),
                      height: 1.5,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _planItems.length,
                padding: const EdgeInsets.only(bottom: 32.0),
                itemBuilder: (context, index) {
                  final item = _planItems[index];
                  return PlanItemRow(
                    title: item['title'] as String,
                    isCompleted: item['isCompleted'] as bool,
                    onToggle: (bool newValue) => _toggleItem(index, newValue),
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
