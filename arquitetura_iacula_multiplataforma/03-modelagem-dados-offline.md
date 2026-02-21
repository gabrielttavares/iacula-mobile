# 03 - Modelagem de Dados Offline

## 1. Objetivo
Garantir funcionamento completo sem internet para conteúdos, configurações, índices e agendamentos.

## 2. Bancos e Papéis
### SQLite (relacional)
Tabelas recomendadas:
- `settings`
- `quote_indices`
- `image_indices`
- `scheduled_events`
- `delivered_events_log`
- `app_meta`

### Isar (NoSQL local)
Coleções recomendadas:
- `quote_documents` (por idioma/tempo)
- `prayer_documents`
- `liturgical_cache` (resultado API por data)
- `media_catalog` (metadados de imagem/áudio)

## 3. Binários (imagens/áudio)
- Persistir no filesystem local do app.
- Guardar no Isar apenas metadados:
  - id
  - path local
  - hash
  - idioma
  - temporada litúrgica
  - tipo (`image`/`audio`)

## 4. Estratégia de Sincronização
1. Seed inicial por assets embarcados.
2. Atualização incremental futura (opcional) por manifesto remoto assinado.
3. Se sem internet, usar cache local sem bloqueio.

## 5. Migração de Dados do Formato Atual
- `config.json` -> tabela `settings`.
- `indices.json` -> `quote_indices` + `image_indices`.
- `assets/quotes/*.json` -> `quote_documents`.
- `assets/prayers/*.json` -> `prayer_documents`.

## 6. Integridade
- Versionar schema (`app_meta.schema_version`).
- Migrations idempotentes.
- Fallback para defaults seguros.
