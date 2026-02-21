# 09 - Roadmap de Migração (Execução)

## Fase 0 - Fundação
- criar novo projeto Flutter
- configurar arquitetura base, DI e módulos
- implementar persistência SQLite + Isar

## Fase 1 - Núcleo de Domínio
- portar entidades e serviços:
  - Settings
  - Quote
  - Prayer
  - QuoteSelector
  - PrayerScheduler
- cobrir com testes unitários

## Fase 2 - Dados e Assets
- implementar seed inicial de assets
- portar repositórios e casos de uso
- validar fallback offline

## Fase 3 - UX Base
- telas principais e settings
- fluxo de quotes e orações

## Fase 4 - Notificações e Alarmes
- scheduler completo
- notificações por tipo de evento
- alarme com tela bloqueada (Android prioritário)
- estratégia equivalente para iOS dentro das limitações

## Fase 5 - Hardening
- testes e2e
- performance
- consumo de bateria
- observabilidade

## Fase 6 - Release Controlado
- beta interno Android/iOS
- correções
- release público gradual

## Critérios de Pronto
- funcionalidades equivalentes ao Electron
- operação offline robusta
- alarmes/notificações confiáveis
- cobertura de testes definida atingida
