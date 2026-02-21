# 04 - Notificações, Alarmes, Vibração e Tela Bloqueada

## 1. Requisitos Funcionais
- Notificar usuário na barra de notificações.
- Permitir agendar lembrete como alarme.
- Chamar usuário para meditação/laudes mesmo com tela bloqueada.
- Vibração configurável.

## 2. Android
- `flutter_local_notifications` com canais dedicados:
  - `quotes_reminder`
  - `angelus_noon`
  - `liturgy_hours_alarm`
- Para alarme crítico:
  - prioridade máxima
  - som customizado
  - vibração customizada
  - Full Screen Intent quando aplicável
- Usar agendamento exato (exact alarms) quando necessário.

## 3. iOS
- Notificações locais com categorias e ações.
- Som crítico onde permitido e aprovado.
- Considerar limitações de background e política do iOS.
- Fallback UX quando full-screen não for permitido.

## 4. Motor de Agendamento
Componente: `SchedulerEngine`
Responsabilidades:
- recalcular próxima execução por evento.
- rearme após reboot/app update.
- idempotência (evitar duplicatas).
- reconciliar agenda ao mudar settings.

## 5. Tipos de Evento
- `quote_interval`
- `angelus_noon`
- `liturgy_hour_laudes`
- `liturgy_hour_vespers`
- `liturgy_hour_compline`
- `liturgy_hour_ora_media`
- `custom_meditation_alarm`

## 6. UX de Alarme
- Tela de alarme com:
  - título
  - texto de meditação/oração
  - botões "Abrir" / "Adiar" / "Concluir"
- Quando bloqueado:
  - abrir full-screen (Android quando permitido)
  - senão notificação persistente de alta prioridade.
