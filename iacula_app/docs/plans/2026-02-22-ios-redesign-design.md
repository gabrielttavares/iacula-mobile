# Iacula App - iOS Modern Redesign Design Document

## 1. Overview
This document outlines the architectural and visual overhaul of the Iacula app from its current dark, traditional theme to a bright, modern, iOS-style aesthetic (inspired by modern Catholic apps).

## 2. Core Aesthetic & Theming
*   **Color Palette:**
    *   **Backgrounds:** Light Gray / Off-white (e.g., `#F2F2F7` - iOS Grouped Background) for scaffolds.
    *   **Cards:** Pure White (`#FFFFFF`) for elevated surfaces.
    *   **Text:** Stark Black (`#000000`) for primary text, Dark Gray (`#8E8E93`) for secondary.
    *   **Accent Color:** A Deep Blue derived from the app's anchor icon (e.g., `#0F4C81` or `#1D3557`), completely replacing the previous gold/brown accents.
*   **Typography:** Bold, large sans-serif headers (iOS large title style). Clean, readable body text.
*   **Shapes:** Generous border radii (e.g., `16.0` to `24.0`) on all cards, buttons, and images.
*   **Shadows:** Very soft, large-spread drop shadows on cards to create depth without harsh lines.

## 3. Global Navigation
*   **Bottom Navigation Bar:** The `AppDrawer` will be removed entirely.
*   **Tabs:**
    1.  **Início** (Home Screen)
    2.  **Orações** (Prayers & Devotions List)
    3.  **Meditação** (Daily Meditation Links)
    4.  **Plano de Vida** (Checklist)
*   The Bottom Nav Bar will be visually clean (either standard `BottomNavigationBar` with no background elevation, or a floating pill-shaped container). The active tab icon will be tinted with the Deep Blue accent.

## 4. Início (Home Screen) Redesign
The Home screen transforms into a modern dashboard.
*   **Header:** "Olá, [User]" in a large bold font (left aligned). A subtle profile or settings icon on the top right.
*   **Hero Image (Jaculatória):** The daily quote card sits right below the header. Large, beautifully rounded (e.g., `24.0` radius), with the image taking up the background and the quote text cleanly overlaid.
*   **Quick Actions:** A horizontal `ListView` of small, rounded square cards or chips (e.g., "Orações", "Rosário", "Novenas") with simple line icons.
*   **Highlights / Banners:** A large, solid-colored (or gradient) banner card that serves as a call-to-action for the "Plano de Vida" (e.g., "Monte sua rotina espiritual"), using the deep blue accent color or a complementary soft tone.

## 5. Plano de Vida (Plan of Life) Redesign
*   **Header:** Bold "Plano de vida" title. Top right action icons for adding custom items (`+`) and settings (`...`).
*   **Date Picker:** A horizontal scrolling row of dates (e.g., "Qua 05", "Qui 06"). The active day is a solid dark pill (Deep Blue or Black), inactive days are subtle gray text.
*   **Sections:** Items are categorized by time of day (Manhã, Tarde, Noite). Each section has a simple, small header with an icon (e.g., a sun for Manhã).
*   **Item Cards:** Each task is a pure white card on the light gray background.
    *   **Left:** A small rounded image or icon thumbnail representing the task.
    *   **Center:** Bold black title ("Oração da Manhã"). Underneath, small gray text indicating frequency or time ("07:00 • Diariamente") and a tiny bell icon if a reminder is active.
    *   **Right:** A rounded action button (checkbox). When checked, it fills with a subtle color and displays a checkmark. When unchecked, it's a light gray outline. A `...` button for editing exists next to the checkbox.

## 6. Development Strategy
1.  **Theme Overhaul:** Update `AppTheme` to define the new light color scheme, typography, and card themes.
2.  **Navigation Implementation:** Replace the Drawer in `main.dart` or an entry shell widget with a `Scaffold` containing a `BottomNavigationBar`. Ensure state preservation between tabs using `IndexedStack` or GoRouter.
3.  **Home Screen Rebuild:** Reconstruct the Home UI according to the dashboard layout (Hero Quote -> Quick Actions -> Plan Banner).
4.  **Plan of Life Rebuild:** Refactor the existing mocked Plan of Life UI to match the new white-card, horizontal-calendar aesthetic.
