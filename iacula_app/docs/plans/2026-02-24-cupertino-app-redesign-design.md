# Iacula App - Cupertino-First Redesign Design Document

## 1. Objective
Migrate the entire app UI to a clean, minimalist, content-first Cupertino experience across all platforms, preserving existing business logic (Riverpod providers, use cases, repositories) and replacing navigation, visual system, and screen composition.

## 2. Product Direction
Design intent:
- Calm
- Structured
- High readability
- Premium but simple
- Not visually noisy

Core principles:
- Large iOS-style titles
- Soft rounded cards
- Subtle elevation (almost flat)
- Neutral grouped background
- Strong hierarchy with generous spacing
- Bottom tab navigation
- SF Pro-style typography scale

## 3. Technical Architecture
### 3.1 App Shell
- Replace `MaterialApp` with `CupertinoApp`.
- Replace `Scaffold + BottomNavigationBar` shell with `CupertinoTabScaffold + CupertinoTabBar`.
- Keep one navigation stack per tab via `CupertinoTabView`.
- Use push-style routes with iOS transitions (`CupertinoPageRoute`).
- Use Cupertino modal sheets for bottom-origin interactions (`showCupertinoModalPopup`).

### 3.2 Tabs
Target tab structure:
1. Início
2. Meditação
3. Plano de vida
4. Favoritos
5. Perfil

Notes:
- Preserve premium gating rules where currently applied.
- Favoritos is introduced in shell and mapped to an existing or new presentation entrypoint during implementation.

## 4. Design System
### 4.1 Color Tokens
- App background: `#F2F2F7`
- Card/surface: `#FFFFFF`
- Primary text: `#111111`
- Secondary text: `#6E6E73`
- Primary CTA background: near-black/navy tone
- CTA text: `#FFFFFF`

### 4.2 Typography Tokens
- Large screen title: `34`, `w700`
- Section title: `22`, `w600`
- Card title: `17`, `w600`
- Secondary/body: `15`, `w400`
- Tab labels: `11`, `w500`

Typography is Cupertino-first and system-like (San Francisco style).

### 4.3 Spacing + Radius Tokens
- Horizontal padding: 16-20
- Vertical spacing between sections: 24-32
- Card gaps: 12-16
- Small radius: 12
- Card radius: 16-20
- Banner radius: 20-24
- Pill buttons: radius = height / 2

### 4.4 Shared Reusable Components
Planned shared UI primitives:
- `IaculaLargeTitle`
- `IaculaSectionHeader`
- `IaculaSoftCard`
- `IaculaPrimaryPillButton`
- `IaculaSecondaryPillButton`
- `IaculaListItem` (avatar + title/subtitle + trailing bookmark)
- `IaculaHorizontalCardRail` (card width ~70% viewport)

## 5. Screen Mapping
### 5.1 Onboarding / Welcome
Structure:
1. Logo top-left
2. Large centered heading
3. Subtitle
4. Two feature cards side-by-side
5. Primary CTA
6. Secondary CTA
7. Footer attribution

### 5.2 Home
Top:
- Logo/leading identity left
- Utility icons right
- Large greeting title

Body:
1. Three square feature cards
2. Large promotional banner card (image + title/subtitle + CTA chip)
3. Destaques horizontal rail
4. Orações diárias vertical list
5. Orações temáticas horizontal rail
6. Orações de Santos vertical list with avatars

### 5.3 Liturgia
Top:
- Large title
- Horizontal day/date chips selector

Body:
- Cupertino segmented control for liturgy parts
- Scrollable content area in soft cards

Calendar:
- Cupertino bottom sheet modal
- Rounded top corners
- Month header + arrows
- Grid calendar
- Full-width confirm button

### 5.4 Perfil
Top:
- Back navigation
- Large title

Body:
- Circular avatar with bottom-right edit affordance
- Sections:
  - Dados da conta (with Edit action)
  - Segurança (with Edit action)
- Spacious rows, subtle separators

### 5.5 Remaining Existing Screens
All existing presentation screens (meditation, prayers, plan of life, premium/paywall, settings/auth actions, alarm) will be migrated to the same Cupertino design language and shared primitives.

## 6. Interaction + Motion
- Subtle transitions only
- iOS spring-like motion where applicable
- Bottom sheets slide from bottom
- No flashy tab transitions
- Tap feedback via opacity/dimming, no Material ripple

## 7. Data Flow and States
- Keep current domain/application layers unchanged.
- UI continues consuming existing providers.
- Standardized states:
  - Loading: `CupertinoActivityIndicator`
  - Empty: neutral white card + concise message
  - Error: readable card + retry action (`Tentar novamente`)
- Replace Material snackbars with Cupertino-aligned feedback patterns.

## 8. Accessibility + Readability
- Strong contrast for primary text on neutral surfaces.
- Large title hierarchy must not collapse readability in smaller devices.
- Respect safe areas and maintain touch-friendly tap targets (>= 44px).

## 9. Validation Strategy
- Preserve behavior while changing presentation.
- Add/update widget tests for:
  1. 5-tab shell structure
  2. Independent tab navigation stacks
  3. Large-title presence on key screens
  4. Liturgy calendar sheet open/close
  5. CTA visual structure (primary/secondary pills)
- Run `flutter test` suite relevant to touched features before completion.

## 10. Non-Goals
- No domain/business rule rewrites.
- No backend/API contract changes.
- No animation-heavy redesign.

