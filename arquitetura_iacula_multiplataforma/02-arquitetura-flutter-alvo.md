# 02 - Arquitetura Flutter Alvo

## 1. Princípios
- Manter arquitetura limpa por camadas.
- Preservar regras de negócio existentes.
- Adaptar infraestrutura para ambiente mobile.
- Offline-first por padrão.

## 2. Estrutura Proposta
`lib/`
- `core/`
  - `di/`
  - `error/`
  - `clock/`
  - `platform/`
- `features/`
  - `settings/`
  - `quotes/`
  - `prayers/`
  - `liturgy_hours/`
  - `notifications/`
  - `liturgical_calendar/`
- `shared/`
  - `widgets/`
  - `theme/`
  - `localization/`

Cada feature com:
- `domain/` (entities + services)
- `application/` (use cases)
- `infrastructure/` (datasources/repos/adapters)
- `presentation/` (state + ui)

## 3. Mapeamento Direto Electron -> Flutter
- `IaculaApp` -> `AppBootstrapper` + `LifecycleCoordinator`
- `TimerManager` -> `SchedulerEngine` (notificações + alarmes)
- `WindowService` -> `Navigation + Overlay/Modal/Screen routes`
- `IPC` -> comunicação interna via camada de estado
- `File*Repository` -> `SQLite/Isar repositories`

## 4. Gerência de Estado
Sugestão principal: `Riverpod`.
- previsível, testável e modular.
- bom encaixe com clean architecture.

## 5. Plugins Recomendados
- Banco relacional: `drift` (SQLite)
- Banco NoSQL local: `isar`
- Notificações: `flutter_local_notifications`
- Timezone: `timezone`
- Permissões: `permission_handler`
- Caminhos de arquivos: `path_provider`
- Vibração: `vibration`

## 6. Compatibilidade Futura
- Android/iOS prioridade.
- Desktop/Web podem ser adicionados com adaptação dos adapters de infra sem quebrar domínio.
