import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import 'apple_sign_in_visibility.dart';

enum _AuthProvider { google, microsoft, apple, signout }

class AuthActionSheet extends StatefulWidget {
  const AuthActionSheet({
    super.key,
    required this.title,
    required this.subtitle,
    this.signedInEmail,
    this.onGoogle,
    this.onMicrosoft,
    this.onApple,
    this.onSignOut,
    this.platformOverride,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final String? signedInEmail;
  final Future<void> Function()? onGoogle;
  final Future<void> Function()? onMicrosoft;
  final Future<void> Function()? onApple;
  final Future<void> Function()? onSignOut;
  final TargetPlatform? platformOverride;
  final bool compact;

  @override
  State<AuthActionSheet> createState() => _AuthActionSheetState();
}

class _AuthActionSheetState extends State<AuthActionSheet> {
  _AuthProvider? _busyProvider;
  String? _errorMessage;

  Future<void> _handleAction(
    _AuthProvider provider,
    Future<void> Function()? action,
  ) async {
    if (action == null || _busyProvider != null) return;

    setState(() {
      _busyProvider = provider;
      _errorMessage = null;
    });

    try {
      await action();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busyProvider = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final platform = widget.platformOverride ?? defaultTargetPlatform;
    final showApple = isAppleSignInAvailable(platform);
    final isSignedIn = widget.signedInEmail != null;

    return IaculaSoftCard(
      padding: widget.compact
          ? const EdgeInsets.all(IaculaSpacing.md)
          : const EdgeInsets.all(IaculaSpacing.lg),
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: IaculaText.cardTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: IaculaText.secondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: IaculaSpacing.lg),
          if (_errorMessage != null) ...[
            IaculaInlineMessage(
              message: _errorMessage!,
              color: IaculaColors.error,
            ),
            const SizedBox(height: IaculaSpacing.md),
          ],
          if (isSignedIn) ...[
            Text(
              'Conectado como ${widget.signedInEmail}',
              textAlign: TextAlign.center,
              style: IaculaText.secondary,
            ),
            const SizedBox(height: IaculaSpacing.md),
            _buildButton(
              label: 'Sair da conta',
              provider: _AuthProvider.signout,
              onPressed: widget.onSignOut,
              primary: false,
            ),
          ] else ...[
            if (showApple && platform == TargetPlatform.iOS) ...[
              _buildButton(
                label: 'Continuar com Apple',
                provider: _AuthProvider.apple,
                onPressed: widget.onApple,
                primary: true,
              ),
              const SizedBox(height: IaculaSpacing.sm),
            ],
            _buildButton(
              label: 'Continuar com Google',
              provider: _AuthProvider.google,
              onPressed: widget.onGoogle,
              primary: !(showApple && platform == TargetPlatform.iOS),
            ),
            const SizedBox(height: IaculaSpacing.sm),
            _buildButton(
              label: 'Continuar com Microsoft',
              provider: _AuthProvider.microsoft,
              onPressed: widget.onMicrosoft,
              primary: false,
            ),
            if (showApple && platform != TargetPlatform.iOS) ...[
              const SizedBox(height: IaculaSpacing.sm),
              _buildButton(
                label: 'Continuar com Apple',
                provider: _AuthProvider.apple,
                onPressed: widget.onApple,
                primary: false,
              ),
            ],
          ],
          const SizedBox(height: IaculaSpacing.lg),
          Text(
            'Ao continuar, você concorda com nossos Termos de Serviço e Política de Privacidade.',
            style: IaculaText.secondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required _AuthProvider provider,
    required Future<void> Function()? onPressed,
    required bool primary,
  }) {
    final isBusy = _busyProvider == provider;
    final isDisabled = _busyProvider != null && !isBusy;
    final action = isDisabled ? null : () => _handleAction(provider, onPressed);

    if (isBusy) {
      return SizedBox(
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: primary
                ? IaculaColors.primaryButton
                : const Color(0x33000000),
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Center(child: CupertinoActivityIndicator()),
        ),
      );
    }

    if (primary) {
      return IaculaPrimaryPillButton(label: label, onPressed: action);
    }

    return IaculaSecondaryPillButton(label: label, onPressed: action);
  }
}
