# 01 - Arquitetura Atual (Mapeamento Completo)

## 1. Stack Atual
- Runtime: Electron
- Linguagem: TypeScript
- Build: `tsc`, `electron-builder`
- UI Desktop: HTML + CSS + controllers TS
- Landing: `web/landing` com Vite + React + TS

## 2. Estrutura Arquitetural
### Domain
- Entidades:
  - `Settings`
  - `Quote`
  - `Prayer`
- Serviços puros:
  - `QuoteSelector`
  - `PrayerScheduler`

### Application
- Use cases:
  - `GetSettingsUseCase`
  - `UpdateSettingsUseCase`
  - `GetNextQuoteUseCase`
  - `GetPrayerUseCase`
- Ports:
  - `ISettingsRepository`
  - `IAssetService`
  - `IIndicesRepository`
  - `IAutoStartService`
  - `IWindowService`
  - `ILiturgicalSeasonService`

### Infrastructure
- Storage:
  - `FileSettingsRepository` (config.json)
  - `FileIndicesRepository` (indices.json)
  - `FileAssetService` (quotes/prayers/images)
- Electron adapters:
  - `WindowService`
  - `AutoStartService`
- Serviço remoto:
  - `RemoteLiturgicalSeasonService`

### Main / Bootstrap
- `IaculaApp` orquestra inicialização.
- `Container` faz DI manual.
- Managers:
  - `TrayManager`
  - `DockManager`
  - `TimerManager`
  - `UpdateManager`
- IPC handlers para comunicação com janelas.

### Presentation
- Telas:
  - popup (jaculatória)
  - angelus
  - regina caeli
  - liturgy reminder
  - settings

## 3. Fluxos Funcionais Atuais
1. Inicializa app e carrega settings.
2. Configura timers de popup e de meio-dia.
3. Busca estação litúrgica (com cache diário).
4. Exibe popup inicial.
5. Em horários configurados, dispara lembrete da Liturgia das Horas.
6. Settings alteram comportamento em runtime.

## 4. Assets Atuais
- `assets/quotes`: 7 arquivos JSON (pt-br, en, la + sazonais pt-br).
- `assets/prayers`: 3 arquivos JSON (pt-br, en, la).
- `assets/images`: 40 imagens (ordinary e sazonais).
- `assets/audio`: 1 áudio de lembrete.

## 5. Scripts e CI
- Scripts de release/versionamento, cópia de assets e manifesto da landing.
- Workflows para release desktop e deploy preview da landing.

## 6. Cobertura de Testes
- Domínio e use cases bem cobertos.
- Testes de integração de serviço litúrgico remoto.
- Testes de timers e single-instance.
- Testes de CI/workflows e módulo landing.
