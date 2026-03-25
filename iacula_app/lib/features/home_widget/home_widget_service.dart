import 'dart:developer' as developer;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../notifications/domain/entities/last_delivered_card.dart';
import 'widget_quote_card.dart';

/// Orchestrates home screen widget updates using the `home_widget` package.
///
/// Saves quote data to shared storage and renders the [WidgetQuoteCard]
/// as a bitmap so native widgets display the exact same visual as in-app.
final class HomeWidgetService {
  HomeWidgetService._();

  static final instance = HomeWidgetService._();

  static const _appGroupId = 'group.com.iacula.app';
  static const _androidWidgetName = 'IaculaWidgetProvider';
  static const _iOSWidgetName = 'IaculaWidget';

  bool _initialized = false;
  final _signatureCache = WidgetCardSignatureCache();

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await HomeWidget.setAppGroupId(_appGroupId);
    _initialized = true;
  }

  /// Updates the home screen widget with the given [card] data.
  ///
  /// 1. Writes key fields to shared storage for native fallback reading.
  /// 2. Renders the Flutter [WidgetQuoteCard] as a PNG for each size variant.
  /// 3. Triggers a native widget refresh.
  Future<bool> updateWidget(LastDeliveredCard card) async {
    try {
      await _ensureInitialized();

      // Write data to shared storage for native access
      await Future.wait([
        HomeWidget.saveWidgetData<String>('quote_text', card.quoteText),
        HomeWidget.saveWidgetData<String>('season', card.season),
        HomeWidget.saveWidgetData<String>('theme', card.theme),
        HomeWidget.saveWidgetData<String?>('feast_name', card.feastName),
        HomeWidget.saveWidgetData<String?>('image_path', card.imagePath),
        HomeWidget.saveWidgetData<String?>('source', card.source),
        HomeWidget.saveWidgetData<String?>(
          'reference_label',
          card.referenceLabel,
        ),
      ]);

      // Render Flutter widget as bitmap for each size variant
      await _renderWidgetImage(
        card,
        key: 'widget_image_small',
        logicalSize: const Size(170, 170),
        showLabel: false,
        fontSize: 13,
      );
      await _renderWidgetImage(
        card,
        key: 'widget_image_medium',
        logicalSize: const Size(364, 170),
        showLabel: true,
        fontSize: 15,
      );
      await _renderWidgetImage(
        card,
        key: 'widget_image_large',
        logicalSize: const Size(364, 364),
        showLabel: true,
        fontSize: 17,
      );

      // Trigger native widget refresh
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: _iOSWidgetName,
      );

      developer.log(
        'Home widget updated successfully.',
        name: 'HomeWidgetService',
      );
      return true;
    } catch (e, st) {
      developer.log(
        'Failed to update home widget: $e',
        name: 'HomeWidgetService',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  Future<bool> updateWidgetIfChanged(LastDeliveredCard card) async {
    if (!_signatureCache.shouldPublish(card)) {
      return false;
    }
    final updated = await updateWidget(card);
    if (updated) {
      _signatureCache.markPublished(card);
    }
    return updated;
  }

  Future<void> _renderWidgetImage(
    LastDeliveredCard card, {
    required String key,
    required Size logicalSize,
    required bool showLabel,
    required double fontSize,
  }) async {
    final widget = WidgetQuoteCard(
      card: card,
      size: logicalSize,
      showLabel: showLabel,
      fontSize: fontSize,
    );

    await HomeWidget.renderFlutterWidget(
      widget,
      key: key,
      logicalSize: logicalSize,
      pixelRatio: ui.PlatformDispatcher.instance.views.first.devicePixelRatio,
    );
  }
}

@visibleForTesting
final class WidgetCardSignatureCache {
  String? _lastSignature;

  bool shouldPublish(LastDeliveredCard card) {
    return signatureOf(card) != _lastSignature;
  }

  void markPublished(LastDeliveredCard card) {
    _lastSignature = signatureOf(card);
  }

  String signatureOf(LastDeliveredCard card) {
    return [
      card.quoteText,
      card.theme,
      card.season,
      card.imagePath ?? '',
      card.feastName ?? '',
      card.source ?? '',
      card.referenceLabel ?? '',
    ].join('|');
  }
}
