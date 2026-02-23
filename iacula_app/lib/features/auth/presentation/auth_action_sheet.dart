import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'apple_sign_in_visibility.dart';

enum _AuthProvider { google, microsoft, apple, signout }

class AuthActionSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? signedInEmail;
  final Future<void> Function()? onGoogle;
  final Future<void> Function()? onMicrosoft;
  final Future<void> Function()? onApple;
  final Future<void> Function()? onSignOut;
  final TargetPlatform? platformOverride;
  final bool compact;

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
    final platform = widget.platformOverride ?? Theme.of(context).platform;
    final showApple = isAppleSignInAvailable(platform);
    final isSignedIn = widget.signedInEmail != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      margin: widget.compact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: widget.compact
            ? const EdgeInsets.all(16)
            : const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (isSignedIn) ...[
              Text(
                'Conectado como ${widget.signedInEmail}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildButton(
                label: 'Sair da conta',
                provider: _AuthProvider.signout,
                onPressed: widget.onSignOut,
                isOutlined: true,
              ),
            ] else ...[
              if (showApple && platform == TargetPlatform.iOS) ...[
                _buildButton(
                  label: 'Continuar com Apple',
                  provider: _AuthProvider.apple,
                  onPressed: widget.onApple,
                ),
                const SizedBox(height: 12),
              ],

              _buildButton(
                label: 'Continuar com Google',
                provider: _AuthProvider.google,
                onPressed: widget.onGoogle,
                isOutlined: showApple && platform == TargetPlatform.iOS,
              ),
              const SizedBox(height: 12),

              _buildButton(
                label: 'Continuar com Microsoft',
                provider: _AuthProvider.microsoft,
                onPressed: widget.onMicrosoft,
                isOutlined: true,
              ),

              if (showApple && platform != TargetPlatform.iOS) ...[
                const SizedBox(height: 12),
                _buildButton(
                  label: 'Continuar com Apple',
                  provider: _AuthProvider.apple,
                  onPressed: widget.onApple,
                  isOutlined: true,
                ),
              ],
            ],

            const SizedBox(height: 24),
            Text(
              'Ao continuar, você concorda com nossos Termos de Serviço e Política de Privacidade.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required _AuthProvider provider,
    required Future<void> Function()? onPressed,
    bool isOutlined = false,
  }) {
    final isBusy = _busyProvider == provider;
    final isDisabled = _busyProvider != null && !isBusy;

    final child = isBusy
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    final action = isDisabled ? null : () => _handleAction(provider, onPressed);

    if (isOutlined) {
      return OutlinedButton(
        onPressed: action,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: child,
      );
    }

    return FilledButton(
      onPressed: action,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: child,
    );
  }
}
