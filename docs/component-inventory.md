# UI Component Inventory — OPERA

> Generated: 2026-02-24 | Scan level: deep

## Design System

**DSFR** (Design System de l'État Français) — Full integration with custom extensions.

- DSFR CSS: 35,909 lines (complete implementation)
- Custom overrides: `application.scss` (375 lines)
- Utility classes: DSFR v1.12.1 utilities
- PDF-specific styles: Custom Marianne font faces for print output
- Theme support: Light, Dark, System (via DSFR theme selector)

## Stimulus Controllers (11)

### 1. session_controller.js
- **Purpose:** Login form validation and dynamic field management
- **Targets:** form, statut, nom, nomBloc, password, submitBouton, error, credentials
- **Behavior:** Shows/hides name field based on user role (2B2O vs Controleur/Bureau Sectoriel). Validates password and status before submission. Fetches available names from `/opera/select_nom`.

### 2. form_controller.js
- **Purpose:** Complex multi-step form validation and conditional field management
- **Targets:** form, submitBouton, fieldRequire, checkRequire, checklist
- **Behavior:** Handles organism and budget forms. Manages conditional visibility of fields based on form state (dissolution, GBCP, control, tutelle, category, operator, employment, credits, accounting, treasury). Real-time validation with DSFR error states. Duplicate detection for organism name/SIREN.

### 3. search_controller.js
- **Purpose:** Autocomplete organism search with accent-insensitive filtering
- **Targets:** form, input, button, listeDeroulante
- **Behavior:** NFD normalization for accent-insensitive matching. Displays results count. Integrates with DSFR modal/collapse components.

### 4. filter_controller.js
- **Purpose:** Simple form submission trigger for filter operations
- **Targets:** form
- **Behavior:** Submits filter form on interaction. Prevents default dropdown behavior.

### 5. tab_controller.js
- **Purpose:** Tab navigation and section visibility management
- **Targets:** section
- **Behavior:** ARIA-compliant tab switching. Manages toggle state and modal opening. Integrates with DSFR tab structure.

### 6. request_controller.js
- **Purpose:** Tag-based filtering and multi-select functionality
- **Targets:** form
- **Behavior:** Creates dynamic tag UI elements with dismiss buttons. Auto-submits form on tag changes. Uses DSFR tag components.

### 7. toggle_controller.js
- **Purpose:** Collapsible sections and comment expand/collapse
- **Targets:** commentaireLong, commentaireCourt, nav
- **Behavior:** Toggle visibility of sections. Smooth scroll navigation. ARIA-compliant state management.

### 8. flatpickr_controller.js
- **Purpose:** Date picker initialization
- **External lib:** flatpickr v4.6.13 (French locale)
- **Behavior:** Formats dates as dd/mm/YYYY. Supports modal container positioning.

### 9. highcharts_controller.js
- **Purpose:** Financial data visualization (charts and graphs)
- **External lib:** Highcharts v11.4.8 with exporting, export-data, offline-exporting, accessibility, data, no-data-to-display modules
- **Targets:** 14 canvas elements (canvasBI, canvasCF, canvasTreso, canvasMS, canvasEmplois, canvasEmploisBis, canvasCharges, canvasProduits, canvasChargesProduits, canvasDepenses, canvasRecettes, canvasDepensesRecettes, canvasTresoBFR, canvasTresoRAP)
- **Chart types:** Stacked bar, line+column combo (spline), synthesized comparisons
- **Data attributes:** datavalue, budgetsbi, budgetscf, abscisses, groupeddatas, series, cb
- **Behavior:** Uses DSFR CSS color variables. Export/download capabilities. Responsive with reflow.

### 10. pdf_export_controller.js
- **Purpose:** Client-side PDF export
- **External libs:** jsPDF v2.5.2, html2canvas v1.4.1
- **Targets:** button
- **Behavior:** Multi-page A4 PDF generation from DOM. Hides print-specific elements. Downloads as 'enquete.pdf'.

### 11. application.js (Stimulus base)
- **Purpose:** Core Stimulus application bootstrap
- **Behavior:** Initializes Stimulus with debug mode disabled.

## View Templates Summary

| Section | Templates | Key Features |
|---------|-----------|--------------|
| **layouts/** | 5 | Application, header, footer, PDF, errors |
| **organismes/** | 20 | Multi-step form, search, tooltips, modals, enquete |
| **chiffres/** | 29 | Budget forms (6 sections), tabs, badges, modals, restitutions, suivi |
| **devise/** | 14+ | Login, registration, password reset, email templates |
| **modifications/** | 6 | Table views, refusal modals, filtering |
| **enquete_reponses/** | 3 | Survey results, charts, PDF export |
| **control_documents/** | 5 | CRUD with file upload |
| **objectifs_contrats/** | 5 | CRUD with file upload |
| **pages/** | 5 | Dashboard, legal, privacy, accessibility, sitemap |
| **errors/** | 3 | 404, 500, 503 error pages |
| **ministeres/** | 2 | List and edit |
| **missions/** | 1 | List |
| **operateurs/** | 4 | CRUD form |
| **users/** | 1 | User list |
| **enquete_questions/** | 1 | Questions by year |

## Navigation Structure (Header)

1. **Accueil** — Dashboard
2. **Organismes** (dropdown)
   - Liste des organismes
   - Créer un nouvel organisme (2B2O only)
   - Modifications (with pending count badge)
3. **Cycle budgétaire** (dropdown)
   - Soumettre un budget (Controleur only)
   - Historique (Controleur only)
   - Liste des budgets
   - Suivi du remplissage
4. **Contrôle interne** (dropdown)
   - Enquêtes CIB-CIC
5. **Documents** (dropdown)
   - Documents de contrôle
   - COP/COM (objectifs contrats)

## DSFR Components Used

- **Layout:** fr-header, fr-footer, fr-container, fr-grid-row, fr-col
- **Navigation:** fr-nav, fr-nav__item, fr-nav__btn, fr-menu, fr-collapse
- **Forms:** fr-form-group, fr-fieldset, fr-input, fr-select, fr-checkbox-group, fr-radio-group
- **Buttons:** fr-btn (primary, secondary, sm, tertiary), fr-btn--search, fr-btn--menu
- **Data display:** fr-table (sticky headers, scroll), fr-card (colored variants), fr-badge, fr-tag
- **Feedback:** fr-alert, fr-modal, tooltips
- **Search:** fr-search-bar with autocomplete modal
- **Pagination:** Custom DSFR-compatible pagination (via pagy helper)
- **Theme:** fr-radio-rich (light/dark/system selector in footer)

## Helper Methods (application_helper.rb)

| Helper | Purpose |
|--------|---------|
| `format_boolean(value)` | true/false/nil → French text |
| `format_date(date)` | Date → dd/mm/yyyy |
| `format_nombre(n)` | French-localized number (1 decimal) |
| `format_nombre_decimal(n)` | French-localized number (2 decimals) |
| `format_nombre_entier(n)` | Integer formatting |
| `ratio(a, b, n)` | Percentage ratio calculation |
| `render_tag_group(title, param, opts)` | DSFR tag group with checkboxes |
| `render_select_group(title, param, opts)` | Tag-based select with dynamic list |
| `class_badge(risque)` | Badge CSS class by solvency risk |
| `numero_br(chiffre)` | Budget rectification number |
| `pagy_nav_custom(pagy)` | DSFR pagination component |

## JavaScript Dependencies (importmap)

| Library | Version | Purpose |
|---------|---------|---------|
| @hotwired/turbo-rails | — | SPA-like navigation |
| @hotwired/stimulus | — | Controller framework |
| stimulus-loading | — | Lazy controller loading |
| flatpickr | 4.6.13 | Date picker (French locale) |
| highcharts | 11.4.8 | Charts (+ 6 modules) |
| jspdf | 2.5.2 | Client-side PDF generation |
| html2canvas | 1.4.1 | DOM to canvas conversion |
| canvg | 3.0.10 | SVG to canvas (Highcharts export) |
| fflate | 0.8.2 | Compression (Highcharts offline export) |
| DSFR | custom | French State Design System JS |
