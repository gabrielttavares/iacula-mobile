import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/confession/domain/entities/confession_examination_item.dart';
import 'package:iacula_app/features/examination/application/examination_flow_notifier.dart';

void main() {
  test('toggleItem selects and unselects ids', () {
    final notifier = ExaminationFlowNotifier();

    notifier.toggleItem('faith_denied');
    expect(notifier.state.selectedItemIds, {'faith_denied'});

    notifier.toggleItem('faith_denied');
    expect(notifier.state.selectedItemIds, isEmpty);
  });

  test('clearAll resets the flow state', () {
    final notifier = ExaminationFlowNotifier();

    notifier.startExamination();
    notifier.toggleItem('faith_denied');

    notifier.clearAll();

    expect(notifier.state.step, ExaminationStep.preparation);
    expect(notifier.state.selectedItemIds, isEmpty);
  });

  test('buildShareText preserves the displayed item order', () {
    final notifier = ExaminationFlowNotifier();
    const items = [
      ConfessionExaminationItem(
        id: 'first',
        text: 'Primeiro item',
        sortOrder: 0,
      ),
      ConfessionExaminationItem(
        id: 'second',
        text: 'Segundo item',
        sortOrder: 1,
      ),
      ConfessionExaminationItem(
        id: 'third',
        text: 'Terceiro item',
        sortOrder: 2,
      ),
    ];

    notifier.toggleItem('third');
    notifier.toggleItem('first');

    expect(notifier.buildShareText(items), 'Primeiro item\nTerceiro item');
  });
}
