# 06 - Estratégia de Migração de Assets

## 1. Origem Atual
- Quotes: `assets/quotes/**`
- Prayers: `assets/prayers/**`
- Images: `assets/images/**`
- Audio: `assets/audio/**`

## 2. Destino Flutter
- manter em `flutter_project/assets/seed/**`
- importar na primeira execução para storage local

## 3. Pipeline de Importação Inicial
1. Ler manifest interno dos assets.
2. Inserir documentos no Isar.
3. Copiar mídias para diretório local do app.
4. Registrar metadados e hash.
5. Marcar `seed_completed=true`.

## 4. Temporadas Litúrgicas
- Manter layout atual por temporada:
  - `ordinary`
  - `advent`
  - `lent`
  - `easter`
  - `christmas`
- Implementar fallback automático para `ordinary`.

## 5. Validação
- checksum por arquivo.
- relatório de seed (sucesso/falha por asset).
- rollback de transação em falha crítica.
