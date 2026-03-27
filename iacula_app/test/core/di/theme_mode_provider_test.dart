import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iacula_app/core/di/providers.dart';

void main() {
  test('themeModeProvider starts as system before settings load', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(themeModeProvider), 'system');
  });
}
