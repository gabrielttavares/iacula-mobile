# 07 - Testes e Qualidade

## 1. Meta
Reproduzir e ampliar a qualidade de testes existente no Electron.

## 2. Camadas de Teste
- Unit (domain/services/usecases)
- Integration (repos, scheduler, liturgical service)
- Widget tests (UI/estado)
- E2E (fluxos críticos de notificação/alarme)

## 3. Cobertura Prioritária
- seleção sequencial de quotes/imagens
- cálculo de agendamento diário
- troca Angelus <-> Regina Caeli por temporada
- persistência e migration de dados
- reconciliação de agenda após mudança de settings

## 4. Testes de Plataforma
- Android instrumentation para comportamento de notificação/alarme
- iOS integration para permissões e triggers locais

## 5. Gate de Qualidade
- lint + format + static analysis
- suite unit/integration obrigatória no PR
- smoke e2e para release candidate
