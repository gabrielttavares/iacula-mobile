import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/more/infrastructure/app_store_review.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  group('appStoreReviewUrisToTry', () {
    test(
      'iOS returns itms-apps write-review then https App Store',
      () {
        final uris = appStoreReviewUrisToTry(TargetPlatform.iOS);
        expect(uris, hasLength(2));
        expect(uris[0].scheme, 'itms-apps');
        expect(uris[0].host, 'itunes.apple.com');
        expect(uris[0].path, '/app/id6761186771');
        expect(uris[0].queryParameters['action'], 'write-review');
        expect(
          uris[1].toString(),
          'https://apps.apple.com/app/id6761186771',
        );
      },
    );

    test('Android returns single Play Store details URL', () {
      final uris = appStoreReviewUrisToTry(TargetPlatform.android);
      expect(uris, hasLength(1));
      expect(
        uris.single.toString(),
        'https://play.google.com/store/apps/details?id=com.iacula.app',
      );
    });

    test('other platforms fall back to https App Store', () {
      final uris = appStoreReviewUrisToTry(TargetPlatform.linux);
      expect(uris, hasLength(1));
      expect(
        uris.single.toString(),
        'https://apps.apple.com/app/id6761186771',
      );
    });
  });

  group('openAppStoreReview', () {
    test('launches first URI that canLaunchUrl accepts', () async {
      final launched = <Uri>[];
      final checked = <Uri>[];

      await openAppStoreReview(
        platform: TargetPlatform.iOS,
        canLaunchUrlFn: (uri) async {
          checked.add(uri);
          return uri.scheme == 'https';
        },
        launchUrlFn: (uri, {LaunchMode mode = LaunchMode.platformDefault}) async {
          launched.add(uri);
          return true;
        },
      );

      expect(checked, hasLength(2));
      expect(checked[0].scheme, 'itms-apps');
      expect(checked[1].scheme, 'https');
      expect(launched, [
        Uri.parse('https://apps.apple.com/app/id6761186771'),
      ]);
    });

    test('stops at first successful canLaunchUrl without trying rest', () async {
      var launchCount = 0;

      await openAppStoreReview(
        platform: TargetPlatform.iOS,
        canLaunchUrlFn: (_) async => true,
        launchUrlFn: (uri, {LaunchMode mode = LaunchMode.platformDefault}) async {
          launchCount++;
          return true;
        },
      );

      expect(launchCount, 1);
    });

    test('never launches when no URI is launchable', () async {
      var launchCount = 0;

      await openAppStoreReview(
        platform: TargetPlatform.android,
        canLaunchUrlFn: (_) async => false,
        launchUrlFn: (uri, {LaunchMode mode = LaunchMode.platformDefault}) async {
          launchCount++;
          return true;
        },
      );

      expect(launchCount, 0);
    });
  });
}
