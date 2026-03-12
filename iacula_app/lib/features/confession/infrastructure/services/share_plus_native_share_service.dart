import 'package:share_plus/share_plus.dart';

import '../../domain/services/native_share_service.dart';

final class SharePlusNativeShareService implements NativeShareService {
  const SharePlusNativeShareService();

  @override
  Future<void> shareText(String text) {
    return SharePlus.instance.share(ShareParams(text: text));
  }
}
