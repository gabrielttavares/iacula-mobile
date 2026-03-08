# Phase 3 Search Discovery Design

**Date:** 2026-03-08

**Goal:** turn search into a clearer and more useful discovery surface for the whole app before revisiting deeper premium gating and meditation taxonomy changes.

## Problem

Phase 1 expanded search from quote-only into a mixed local search. That solved the expectation gap, but the current experience is still shallow:

- results are flat, without sections
- ranking is minimal and mostly order-of-load
- no recent queries or suggestions appear in the empty state
- quote results still behave like a lightweight modal fallback
- search does not yet feel like a trustworthy discovery layer for the whole product

## Recommended Approach

Keep search local and structured.

This phase should not add remote search, semantic search, or a command-palette interaction model. Instead it should improve the current mixed search into a stronger discovery system using the local content already available in the app.

## Search Experience

### Empty state

When no query is active, search should show lightweight discovery guidance:

- recent queries if available
- a few suggested themes/titles
- clear invitation to search across prayers, meditations, readings, and quotes

### Results

Results should be grouped by section:

- Orações
- Meditações
- Leituras
- Citações

Within each section, results should be ranked by relevance.

### Ranking

The ranking model should stay simple and deterministic:

- exact title match highest
- prefix title match next
- title contains match next
- tag/theme/saint/source match after that
- snippet/body match last

This is enough to make the list feel intentional without adding heavy search infrastructure.

## Architecture

The current `AppSearchService` should evolve into a more explicit discovery service contract.

Each result should expose:

- type
- section
- score
- title
- subtitle
- snippet
- destination metadata

This remains a UI-facing application layer, not a domain-wide abstraction.

## Navigation

Navigation should remain direct by type:

- prayer -> prayer detail
- meditation -> meditation detail
- reading -> reading screen
- quote -> keep the fallback modal for now unless an existing detail destination is already available

The key improvement is not a new route, but better search comprehension and ranking.

## Premium Scope

Premium is not the primary target of this phase.

The only requirement is that discovery should not feel broken when content is gated. Search should still help the user understand what exists, while actual enforcement can stay where it already is unless a low-risk improvement becomes obvious during implementation.

## Non-Goals

Out of scope:

- remote search
- semantic/vector search
- full meditation taxonomy rewrite
- broad premium flow redesign
- command-palette search shell

## Testing

Phase 3 should add:

- ranking tests for the discovery service
- section grouping tests
- widget tests for empty state, recent queries, and suggested search chips
- navigation tests by result type
- regression tests ensuring `Meditação` and `Plano de vida` labels remain unchanged where relevant

## Success Criteria

Phase 3 is successful if:

- search feels obviously broader and more useful than a flat result list
- top matches are relevant and stable
- empty search still helps the user discover what to do
- results are grouped in a way that matches user mental models
