import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/design/iacula_input.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/keyboard_dismiss.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../auth/presentation/auth_action_sheet.dart';
import '../../custom_phrases/presentation/custom_phrases_screen.dart';
import '../../notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import '../../premium/domain/entities/premium_feature.dart';
import '../../premium/presentation/premium_gate.dart';
import '../domain/entities/settings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _intervalController;

  String _language = 'pt-br';
  bool _onboardingCompleted = false;
  String _themeMode = 'dark';

  bool _loading = true;
  bool _saving = false;
  String? _validationMessage;

  // Kept for backward compat — always use defaults when saving
  late Settings _loadedSettings;

  @override
  void initState() {
    super.initState();
    _intervalController = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final settings = await ref.read(getSettingsUseCaseProvider).call();
    _loadedSettings = settings;
    _intervalController.text = settings.intervalMinutes.toString();
    _language = settings.language;
    _onboardingCompleted = settings.onboardingCompleted;
    _themeMode = settings.themeMode;

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: IaculaKeyboardDismiss(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text('Configurações'),
              backgroundColor: context.colors.background,
              border: null,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(IaculaSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── APARÊNCIA ──
                  const IaculaSectionHeader(title: 'Aparência'),
                  const SizedBox(height: IaculaSpacing.sm),
                  IaculaSoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel(context, 'Tema'),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl<String>(
                            groupValue: _themeMode,
                            padding: const EdgeInsets.all(4),
                            children: const {
                              'light': Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Text('Claro'),
                              ),
                              'dark': Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Text('Escuro'),
                              ),
                              'system': Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Text('Sistema'),
                              ),
                            },
                            onValueChanged: (value) {
                              if (value != null) {
                                HapticFeedback.selectionClick();
                                setState(() => _themeMode = value);
                                ref.read(themeModeProvider.notifier).state =
                                    value;
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: IaculaRadius.elementSpacing),
                        _fieldLabel(context, 'Tamanho da fonte'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(CupertinoIcons.textformat_size, size: 14),
                            Expanded(
                              child: CupertinoSlider(
                                value: _loadedSettings.prayerFontSize,
                                min: 12,
                                max: 24,
                                divisions: 12,
                                activeColor: context.colors.primaryButton,
                                onChanged: (value) {
                                  setState(() {
                                    _loadedSettings = _loadedSettings.copyWith(
                                      prayerFontSize: value,
                                    );
                                  });
                                },
                              ),
                            ),
                            const Icon(CupertinoIcons.textformat_size, size: 22),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.colors.separator,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Exemplo de oração nesta escala',
                            textAlign: TextAlign.center,
                            style: context.textStyles.readingBody.copyWith(
                              fontSize: _loadedSettings.prayerFontSize,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── NOTIFICAÇÕES ──
                  const SizedBox(height: IaculaRadius.cardSpacing),
                  const IaculaSectionHeader(title: 'Notificações'),
                  const SizedBox(height: IaculaSpacing.sm),
                  IaculaSoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel(
                          context,
                          'Intervalo das jaculatórias (minutos)',
                        ),
                        const SizedBox(height: 8),
                        IaculaTextInput(
                          controller: _intervalController,
                          placeholder: '1..60',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),

                  // ── PERSONALIZAÇÃO ──
                  const SizedBox(height: IaculaRadius.cardSpacing),
                  const IaculaSectionHeader(title: 'Personalização'),
                  const SizedBox(height: IaculaSpacing.sm),
                  IaculaSoftCard(
                    padding: EdgeInsets.zero,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: IaculaRadius.innerPadding,
                        vertical: 16,
                      ),
                      onPressed: () {
                        final isPremium =
                            ref
                                .read(premiumStatusProvider)
                                .valueOrNull
                                ?.isPremium ??
                            false;
                        if (!isPremium) {
                          PremiumGate.showModal(
                            context,
                            feature: PremiumFeature.meditation,
                          );
                          return;
                        }
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const CustomPhrasesScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            'Minhas frases',
                            style: context.textStyles.cardTitle.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            CupertinoIcons.chevron_right,
                            color: context.colors.textSecondary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── CONTA ──
                  const SizedBox(height: IaculaRadius.cardSpacing),
                  const IaculaSectionHeader(title: 'Conta'),
                  const SizedBox(height: IaculaSpacing.sm),
                  _buildAuthSyncSection(),

                  if (_validationMessage != null) ...[
                    const SizedBox(height: IaculaSpacing.md),
                    IaculaInlineMessage(
                      message: _validationMessage!,
                      color: context.colors.error,
                    ),
                  ],

                  const SizedBox(height: IaculaSpacing.lg),
                  CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(26),
                    onPressed: _saving
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            _save();
                          },
                    child: Text(_saving ? 'Salvando...' : 'Salvar'),
                  ),
                ]),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + IaculaSpacing.md,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: context.textStyles.secondary),
    );
  }

  Widget _buildAuthSyncSection() {
    final authState = ref.watch(authStateProvider);
    final authRepo = ref.read(authRepositoryProvider);
    final user = authState.valueOrNull;

    return AuthActionSheet(
      title: 'Sincronização entre dispositivos',
      subtitle:
          'Faça login para manter seus dados espirituais sincronizados entre dispositivos. A sincronização acontece automaticamente.',
      signedInEmail: user?.email,
      onGoogle: () => authRepo.signInWithGoogle(),
      onMicrosoft: () => authRepo.signInWithMicrosoft(),
      onApple: () => authRepo.signInWithApple(),
      onSignOut: () => authRepo.signOut(),
    );
  }

  Future<void> _save() async {
    setState(() => _validationMessage = null);
    final interval = int.tryParse(_intervalController.text);
    if (interval == null || interval < 1 || interval > 60) {
      setState(
        () => _validationMessage = 'O intervalo deve ser entre 1 e 60 minutos.',
      );
      return;
    }

    setState(() => _saving = true);

    // Preserve liturgy fields at their loaded values for backward compat
    final settings = _loadedSettings.copyWith(
      intervalMinutes: interval,
      language: _language,
      onboardingCompleted: _onboardingCompleted,
      themeMode: _themeMode,
    );

    await ref.read(updateSettingsUseCaseProvider).call(settings);

    final schedulerRepo = ref.read(notificationSchedulerRepositoryProvider);
    await schedulerRepo.cancelAll();
    await ScheduleCoreRemindersUseCase(
      schedulerRepo,
      quoteFetcher: ({required String language, required DateTime now}) {
        if (settings.escrivaPointsFeedEnabled) {
          return ref
              .read(getNextEscrivaPointsQuoteUseCaseProvider)
              .call(language: language, now: now);
        }

        return ref
            .read(getNextQuoteUseCaseProvider)
            .call(language: language, now: now);
      },
      lastDeliveredCardRepository: ref.read(
        lastDeliveredCardRepositoryProvider,
      ),
    ).call(settings);

    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop(true);
    }
  }
}
