import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/providers.dart';

class LocalOnlyBanner extends ConsumerWidget {
  const LocalOnlyBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(bootstrapStatusProvider);

    if (!status.isLocalOnly) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFFFF3CD),
      child: const Row(
        children: [
          Icon(CupertinoIcons.exclamationmark_triangle, size: 16, color: Color(0xFF856404)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Usando modo local \u2014 dados n\u00e3o ser\u00e3o sincronizados.',
              style: TextStyle(fontSize: 13, color: Color(0xFF856404)),
            ),
          ),
        ],
      ),
    );
  }
}
