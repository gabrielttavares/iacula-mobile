import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';

class MeditationWebContent extends StatefulWidget {
  const MeditationWebContent({
    super.key,
    required this.url,
    required this.title,
    this.fallback,
  });

  final String url;
  final String title;
  final Widget? fallback;

  @override
  State<MeditationWebContent> createState() => _MeditationWebContentState();
}

class _MeditationWebContentState extends State<MeditationWebContent> {
  late final WebViewController _controller;
  int _progress = 0;
  String? _lastError;

  @override
  void initState() {
    super.initState();

    PlatformWebViewControllerCreationParams params =
        const PlatformWebViewControllerCreationParams();

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _progress = 0;
              _lastError = null;
            });
          },
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _progress = progress);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _progress = 100);
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() {
              _lastError = error.description;
              _progress = 100;
            });
          },
        ),
      );

    final platformController = _controller.platform;
    if (platformController is AndroidWebViewController) {
      if (kDebugMode) {
        AndroidWebViewController.enableDebugging(true);
      }
      platformController.setMediaPlaybackRequiresUserGesture(false);
    }

    _loadUrl();
  }

  @override
  void didUpdateWidget(covariant MeditationWebContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _loadUrl();
    }
  }

  Future<void> _loadUrl() async {
    await _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IaculaRadius.card),
        child: Stack(
          fit: StackFit.expand,
          children: [
            WebViewWidget(controller: _controller),
            if (_lastError != null && widget.fallback != null) widget.fallback!,
            if (_lastError != null && widget.fallback == null)
              _WebErrorState(
                title: widget.title,
                message: _lastError!,
                onRetry: _loadUrl,
              ),
            if (_progress < 100 && _lastError == null)
              ColoredBox(
                color: context.colors.card,
                child: const Center(
                  child: CupertinoActivityIndicator(radius: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WebErrorState extends StatelessWidget {
  const _WebErrorState({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.card,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(IaculaSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle,
                color: context.colors.textSecondary,
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.textStyles.cardTitle,
              ),
              const SizedBox(height: 8),
              Text(
                'Não foi possível carregar este conteúdo agora.',
                textAlign: TextAlign.center,
                style: context.textStyles.secondary,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: IaculaSpacing.md,
                  vertical: IaculaSpacing.sm,
                ),
                color: context.colors.primaryButton,
                onPressed: () => onRetry(),
                child: Text(
                  'Tentar novamente',
                  style: TextStyle(
                    color: context.colors.background,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
