import 'package:flutter/foundation.dart';

bool isAppleSignInAvailable(TargetPlatform platform) {
  return platform == TargetPlatform.iOS;
}
