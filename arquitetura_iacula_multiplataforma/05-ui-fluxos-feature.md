# 05 - UI e Fluxos de Funcionalidades

## 1. Telas Flutter
- `HomeScreen` (resumo espiritual do dia)
- `QuoteCardScreen` (equivalente popup)
- `PrayerScreen` (Angelus/Regina Caeli)
- `LiturgyReminderScreen`
- `SettingsScreen`
- `AlarmRingScreen` (quando alarmes críticos)

## 2. Fluxos Principais
### A. Jaculatória periódica
1. Scheduler dispara evento.
2. Use case seleciona quote e imagem por dia/temporada.
3. Notificação exibida.
4. Ao abrir, mostrar `QuoteCardScreen`.

### B. Angelus/Regina Caeli
1. Scheduler dispara às 12h.
2. Resolve temporada litúrgica.
3. Seleciona oração correta.
4. Notificação/tela exibida.

### C. Liturgia das Horas
1. Usuário habilita módulos e horários.
2. Scheduler cria eventos diários por módulo.
3. Disparo abre notificação e opção de abrir ofício.

## 3. Configurações Migradas
- intervalo e duração de lembrete
- idioma
- som/volume
- módulos litúrgicos e horários
- autostart equivalente mobile (ajustado para plataforma)
- vibração e modo alarme

## 4. Localização
- Base inicial: `pt-BR`
- manter `en` e `la`
- estruturar i18n com ARB (`flutter_localizations` + `intl`)
