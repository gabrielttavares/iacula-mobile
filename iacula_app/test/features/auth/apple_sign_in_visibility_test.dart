import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/auth/presentation/apple_sign_in_visibility.dart';

void main() {
  test('apple sign-in is available only on iOS', () {
    expect(isAppleSignInAvailable(TargetPlatform.iOS), isTrue);
    expect(isAppleSignInAvailable(TargetPlatform.android), isFalse);
    expect(isAppleSignInAvailable(TargetPlatform.macOS), isFalse);
  });
}
