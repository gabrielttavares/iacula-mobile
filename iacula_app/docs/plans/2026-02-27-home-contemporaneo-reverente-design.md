# Home Redesign Design — Contemporâneo Reverente (80/20)

## Contexto
O app já evoluiu bem na direção Cupertino/iOS, mas a Home ainda está mais funcional do que memorável. O objetivo é aumentar a beleza percebida sem perder clareza e consistência.

Direção validada:
- Estilo: **Contemporâneo reverente**
- Intensidade: **80/20** (80% iOS clean, 20% elementos sacros sutis)
- Tela padrão-ouro inicial: **Home**
- Emoção dominante: **Acolhimento**

## Objetivo
Tornar a Home mais acolhedora e distintiva para um app católico, preservando:
- linguagem Cupertino como base,
- padrões já definidos de modal/input/feedback/nav,
- lógica de negócio e fluxos de navegação atuais.

## Abordagens Consideradas

### 1) Atmosfera por camadas (recomendada)
Base Cupertino limpa + camada sacra leve (cor, textura, tipografia pontual, microcopy).
- Prós: preserva usabilidade e consistência; melhora identidade sem exagero.
- Contras: exige disciplina visual para não virar "genérico bonito".

### 2) Hero editorial forte
Hero muito destacado e artístico; restante minimalista.
- Prós: alto impacto de marca imediato.
- Contras: risco de parecer desconectado das demais telas.

### 3) Ritual funcional
Prioriza clareza e ritmo de fluxo, estética mais contida.
- Prós: excelente execução prática.
- Contras: menor memorabilidade visual.

Decisão: **Abordagem 1 (Atmosfera por camadas)**.

## Seção 1 — Arquitetura Visual da Home
- Topo acolhedor com saudação + contexto litúrgico do dia, sem poluição.
- Card principal de “momento espiritual” como foco emocional e CTA primário.
- Grade de ações espirituais com hierarquia clara (Plano de Vida, Orações, Liturgia etc.).
- Bloco de continuidade (“retomar de onde parou”) ao final da primeira leitura.

Linguagem visual:
- Fundo claro quente (off-white), evitando branco puro clínico.
- Azul funcional atual permanece como cor estrutural.
- Acento sacro (dourado queimado) apenas em destaque e estado especial.
- Tipografia de interface segue padrão iOS; serifada aparece só em títulos devocionais-chave.
- Ícones Cupertino permanecem base; símbolos católicos apenas quando semanticamente úteis.

Regra 80/20:
- 80%: componentes padrão/tokens Cupertino existentes.
- 20%: hero, paleta de apoio, headline e detalhes de atmosfera.

## Seção 2 — Componentes e Comportamento

### HomeHeroCard
- Conteúdo: título breve, subtítulo espiritual, CTA principal.
- Visual: raio suave, profundidade leve, gradiente quente sutil.
- Estados: loading/skeleton, empty contextual, error com retry.

### HomeActionGrid
- Cartões com ícone + título + linha de contexto.
- Altura e espaçamento fixos para ritmo visual consistente.
- Press states Cupertino mais perceptíveis.

### HomeContinuationCard
- “Continue seu caminho” com último conteúdo/recurso relevante.

Microinterações:
- Entrada em stagger leve na primeira dobra.
- Transições curtas e discretas, priorizando fluidez e legibilidade.

Decisões de UX:
- Acolhimento vem antes de produtividade (hero primeiro).
- Ações práticas continuam acima da dobra.
- Sem mudança de arquitetura de navegação nesta fase.
- Copy em português devocional simples, menos tom genérico de produto.

## Seção 3 — Data Flow, Estados e Qualidade
- Reaproveitar providers/use cases atuais; apenas recomposição da camada de apresentação.
- Composição por blocos: `HomeHeroCard`, `HomeActionGrid`, `HomeContinuationCard`.
- Sem alteração em entidades/repositórios/regras de domínio.

Error handling:
- Estado explícito por bloco: `loading`, `empty`, `error`, `data`.
- Erro local com `IaculaErrorState` inline e ação de retry.
- Falha de um bloco não derruba a Home inteira.

Qualidade/Testes mínimos:
- Widget tests cobrindo render e fallback de cada bloco.
- Teste de hierarquia visual (hero antes da grade).
- Testes básicos de acessibilidade (tap target e labels).
- Golden tests da Home em duas larguras para proteção visual.

## Critérios de Sucesso
- Em ~3 segundos, sensação dominante é de acolhimento.
- Em uma rolagem curta, rotinas principais estão claras.
- Home fica mais bela e distintiva sem quebrar consistência Cupertino do app.

## Fora de Escopo
- Redesenho completo de todas as telas nesta etapa.
- Mudanças de backend, contratos de dados ou regras de notificação.
- Mudança ampla de navegação/roteamento.
