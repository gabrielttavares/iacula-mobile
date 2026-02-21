# Arquitetura Mestre - Iacula Multiplataforma (Flutter)

## 1. Objetivo
Migrar o projeto `iacula-main` (Electron + TypeScript) para Flutter multiplataforma, com prioridade em Android e iOS, preservando comportamento funcional: jaculatórias periódicas, Angelus/Regina Caeli, Liturgia das Horas, configurações, notificações e lembretes com alarme.

## 2. Escopo Mapeado do Repositório Atual
Este plano foi construído após análise de:
- `src/**` (main/bootstrap, domain, application, infrastructure, presentation)
- `assets/**` (quotes, prayers, images, audio)
- `tests/**` (domain/application/infrastructure/main/ci)
- `scripts/**` (build, copy-assets, release, manifest)
- `docs/**`
- `.github/workflows/**`
- `web/landing/**`

## 3. Estado Atual (Resumo)
- Arquitetura limpa por camadas (Domain -> Application -> Infrastructure -> Presentation) com composição manual no `Container`.
- App desktop com múltiplas janelas e timers para popups e orações.
- Persistência atual em JSON local (config e índices).
- Conteúdo local em assets JSON + imagens + áudio.
- Dependência remota para estação litúrgica (`liturgia.up.railway.app/v2`).
- Testes consistentes em regras de negócio e integração técnica.

## 4. Arquitetura Alvo Flutter
- Manter a separação por camadas no Flutter.
- Mobile-first (Android/iOS), com desktop/web opcionais depois.
- Offline-first completo.
- Engine de agendamento local robusta para notificações e alarmes.

Documentos detalhados:
1. `01-arquitetura-atual-mapeamento.md`
2. `02-arquitetura-flutter-alvo.md`
3. `03-modelagem-dados-offline.md`
4. `04-notificacoes-alarmes-vibracao.md`
5. `05-ui-fluxos-feature.md`
6. `06-migracao-assets.md`
7. `07-testes-qualidade.md`
8. `08-devops-ci-cd.md`
9. `09-roadmap-migracao.md`

## 5. Decisão de Persistência Offline (Solicitação Principal)
### Decisão
- Dados relacionais/configuração/agenda: `SQLite`.
- Conteúdo estruturado flexível e cache de documentos: `Isar` (NoSQL local).
- Imagens e áudio: arquivo local em `ApplicationDocumentsDirectory` + metadados em Isar.

### Justificativa
- SQLite cobre bem configurações, índices, agendas e queries relacionais.
- Isar oferece performance alta para documentos/coleções locais, indexação e integração Flutter.
- Binários grandes em banco tendem a degradar performance; manter arquivo no sistema e indexar no banco é mais estável.

## 6. Alarmes e Tela Bloqueada
- Android: `flutter_local_notifications` + agendamento exato + Full Screen Intent para alarme crítico.
- iOS: notificações locais com som crítico (quando permitido), fallback para alerta padrão e UX específica para limites de background iOS.
- Vibração: plugin dedicado com padrões por tipo de lembrete.

## 7. Riscos Críticos da Migração
- Restrições de background no iOS para comportamento de "alarme" contínuo.
- Diferenças de semântica de timers do desktop para mobile.
- Necessidade de política clara de fallback quando API litúrgica estiver indisponível.

## 8. Entrega Esperada
A arquitetura aqui proposta permite:
- comportamento funcional equivalente ao app atual;
- persistência offline robusta;
- evolução segura por módulos;
- qualidade sustentada por testes unitários, integração e e2e.
