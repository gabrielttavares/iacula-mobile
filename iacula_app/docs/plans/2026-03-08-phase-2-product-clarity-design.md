# Phase 2 Product Clarity Design

**Date:** 2026-03-08

**Goal:** make the product easier to understand within the first few seconds of use, especially on Home and onboarding, without introducing high-risk navigation or domain-model changes.

## Problem

Phase 1 improved copy, search breadth, premium messaging basics, and data credibility. The app is clearer than before, but the product still relies too much on users interpreting a catalog of features.

The main remaining clarity problem is structural:

- Home still behaves mostly like a feature hub.
- Onboarding still explains what exists more than what the user should do next.
- Premium messaging is less blunt, but still secondary to the product understanding problem.

## Product Direction

Home should be guided first and exploratory second.

The first screen should answer three questions immediately:

1. What is this app helping me do right now?
2. What is the best next step?
3. Where do I go if I want something else?

That implies a Home hierarchy with a primary action at the top, followed by practical shortcuts, followed by exploration rails.

## Recommended Approach

Use a guided Home with an actionable hero.

Why this approach:

- It solves the clarity problem directly.
- It works with the current architecture and content sources.
- It avoids inventing a more editorial system that would require new curation logic.
- It keeps risk lower than a broader IA rewrite.

## Home Experience

### Top section

The hero should become a practical prayer entry point instead of a mostly atmospheric module.

It should contain:

- a short situational heading
- one concrete recommended action
- one supporting line that explains why this is a good next step
- a primary CTA that opens the recommended content

The visual result should feel like "start here now", not "browse the app".

### Secondary section

The current action grid remains, but it becomes explicitly secondary to the hero.

The section should read as quick access for users who already know what they want.

### Exploration section

Thematic prayers, saints, novenas, and readings stay below the guided action.

These remain important, but their role becomes discovery after the primary action is understood.

## Onboarding Experience

Onboarding should shift from feature inventory to a short promise plus proof.

The structure should be:

- one core promise
- up to three supporting proofs
- a primary CTA that starts the product journey
- a secondary CTA for using the app without an account

The copy should answer:

- why the app is useful
- what kind of spiritual rhythm it supports
- why returning daily makes sense

## Premium Scope For Phase 2

Premium is not the main focus of this phase.

Only light adjustments are included:

- keep premium copy aligned with the new Home/onboarding clarity
- avoid premium interruption stealing attention from the primary "what do I do now?" journey

This phase should not redesign paywall architecture or introduce deeper gating logic changes.

## Architecture

This phase should stay presentation-led.

Expected shape:

- reuse existing providers and domain data where possible
- add small presentation models/helpers if the hero needs a clearer "recommended next step" contract
- keep navigation unchanged unless a clearer CTA target requires existing route wiring

No new backend service or remote dependency should be introduced in this phase.

## Error Handling

Error states in the hero and onboarding-adjacent surfaces should stay actionable and non-technical.

Pattern:

- what failed
- what the user can do next
- retry when relevant

## Testing

This phase should update and extend:

- widget tests for Home hierarchy and CTA behavior
- onboarding widget tests for revised messaging and CTA labels
- golden tests for Home and onboarding where layout visibly changes
- regression tests ensuring the hero appears before quick actions and exploration rails

## Non-Goals

These stay out of scope for Phase 2:

- major premium flow redesign
- server-backed or semantic search
- large devotional data model changes
- navigation architecture changes
- new content systems tied to time-of-day curation

## Success Criteria

Phase 2 is successful if:

- a new user can infer the app's purpose from Home and onboarding quickly
- Home presents one obvious next step before exploration content
- onboarding feels like a reason to stay, not a list of features
- tests and goldens clearly lock the new hierarchy in place
