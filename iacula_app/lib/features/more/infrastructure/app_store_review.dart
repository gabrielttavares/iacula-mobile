import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

const _appleAppStoreId = '6761186771';
const _androidPackageId = 'com.iacula.app';

/// Public store page of the app, for links in shared content. Points at the
/// sharer's own store; there is no universal link domain yet.
String iaculaStoreUrl(TargetPlatform platform) =>
    platform == TargetPlatform.android
    ? 'https://play.google.com/store/apps/details?id=$_androidPackageId'
    : 'https://apps.apple.com/app/id$_appleAppStoreId';

/// URIs to try in order for the platform-specific app review / store flow.
List<Uri> appStoreReviewUrisToTry(TargetPlatform platform) {
  switch (platform) {
    case TargetPlatform.iOS:
      return [
        Uri.parse(
          'itms-apps://itunes.apple.com/app/id$_appleAppStoreId?action=write-review',
        ),
        Uri.parse('https://apps.apple.com/app/id$_appleAppStoreId'),
      ];
    case TargetPlatform.android:
      return [
        Uri.parse(
          'https://play.google.com/store/apps/details?id=$_androidPackageId',
        ),
      ];
    default:
      return [Uri.parse('https://apps.apple.com/app/id$_appleAppStoreId')];
  }
}

/// Opens the store review flow using the first [Uri] that the platform reports
/// as launchable.
Future<void> openAppStoreReview({
  TargetPlatform? platform,
  Future<bool> Function(Uri uri)? canLaunchUrlFn,
  Future<bool> Function(Uri uri, {LaunchMode mode})? launchUrlFn,
}) async {
  final p = platform ?? defaultTargetPlatform;
  final canLaunch = canLaunchUrlFn ?? canLaunchUrl;
  Future<bool> doLaunch(Uri uri, {LaunchMode mode = LaunchMode.externalApplication}) {
    final injected = launchUrlFn;
    if (injected != null) {
      return injected(uri, mode: mode);
    }
    return launchUrl(uri, mode: mode);
  }

  for (final uri in appStoreReviewUrisToTry(p)) {
    if (await canLaunch(uri)) {
      await doLaunch(uri);
      return;
    }
  }
}
