import 'package:flutter/cupertino.dart';

import '../../../core/theme/cupertino_tokens.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF15110D),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: IaculaText.sectionTitle.copyWith(
                  color: IaculaColors.primaryButton,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                style: IaculaText.secondary.copyWith(
                  color: CupertinoColors.systemGrey4,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Concluir'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
