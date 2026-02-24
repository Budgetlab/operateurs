---
stepsCompleted:
  - step-01-init
  - step-02-discovery
  - step-02b-vision
  - step-02c-executive-summary
  - step-03-success
  - step-04-journeys
inputDocuments:
  - docs/plan-refactoring-operateur.md
  - docs/project-overview.md
  - docs/architecture.md
  - docs/data-models.md
workflowType: 'prd'
documentCounts:
  briefs: 0
  research: 0
  brainstorming: 0
  projectDocs: 4
classification:
  projectType: web_app
  domain: govtech
  complexity: high
  projectContext: brownfield
---

# Product Requirements Document - Operateurs Refactoring

**Author:** Alexandra
**Date:** 2026-02-24

## Executive Summary

OPERA is a production government web application managing French public organisms for the Direction du Budget. The operateur tracking system currently uses four hardcoded boolean columns (`operateur_nf`, `operateur_n`, `operateur_n1`, `operateur_n2`) representing a 4-year sliding window of operator status. This architecture forces a complete annual data reimport to shift years, limits historical records to 4 years, and scatters brittle conditional logic across 15 files (models, controllers, views, exports, JavaScript).

This refactoring replaces the four booleans with an `annees integer[]` column on `operateurs` and an `operateur_actif boolean` on `organismes`, shifting from a "snapshot" model to a "lifecycle" model. When an operator is active, only the start year is stored; when deactivated, all years are expanded into the array. This eliminates the annual reimport process, provides unlimited historical tracking, simplifies the codebase, and improves data reliability by reducing manual manipulation.

All three user roles are impacted: 2B2O (administration and imports), Contrôleurs (budget creation and organism editing), and Bureaux Sectoriels (read-only consultation). The Excel import format remains unchanged — adaptation happens server-side.

### What Makes This Special

The core insight is a conceptual shift from **point-in-time snapshots** to **lifecycle tracking**. Instead of photographing operator status at 4 fixed dates, the system records when an operator becomes active or inactive. This single architectural change cascades into: no annual maintenance, unlimited history, simpler queries (`operateur_pour_annee?(year)` vs. checking specific booleans), a cleaner UI (one toggle vs. four radio button groups), and simplified filtering (one `operateur_actif` flag vs. complex null-check logic spanning 19 lines in the controller).

## Project Classification

- **Project Type:** Web application (Rails 8.1 MVC + Hotwire, DSFR design system)
- **Domain:** Govtech — French government budget directorate tooling
- **Complexity:** High — Regulated domain, budgetary data integrity, multi-role authorization, DSFR/RGAA accessibility compliance, production data migration required
- **Project Context:** Brownfield — Existing production application, refactoring a core feature with data migration

## Success Criteria

### User Success

- **2B2O administrators** no longer perform annual operateur data reimports. Operator status is managed through activation/deactivation lifecycle, not bulk overwrites.
- **Contrôleurs** see complete operator history for their organisms — not limited to a 4-year window. When viewing an organism, the full timeline of active/inactive periods is visible.
- **Bureaux Sectoriels** access the same historical data in read-only mode with no disruption to their workflow.
- **All roles** experience the transition transparently: existing functionality works identically, the interface feels natural rather than alien.

### Business Success

- **Elimination of annual maintenance overhead**: The yearly operateur reimport process (currently required to shift year booleans) is completely removed from the operational calendar.
- **Unlimited historical tracking**: Operator status can be queried for any year, enabling long-term trend analysis and audit compliance.
- **Reduced support burden**: Fewer data manipulation steps mean fewer errors and fewer support requests related to operateur status discrepancies.

### Technical Success

- **Zero data loss**: All existing operateur boolean data is correctly migrated to the new `annees` array format. Migration is reversible. Year mapping: nf=2027, n=2026, n1=2025, n2=2024.
- **All tests pass**: Existing test suite passes without regression. New unit tests cover `operateur_pour_annee?`, `toutes_annees`, `activer!`, `desactiver!`.
- **Performance parity**: Page load times for organism index, show, and export pages remain within current benchmarks. GIN index on `annees` ensures query performance.
- **Code simplification**: Net reduction in lines of code. The 19-line filter logic in `organismes_controller.rb` (lines 28-46) reduces to a single `operateur_actif_in` filter.

### Measurable Outcomes

| Metric | Current | Target |
|--------|---------|--------|
| Annual reimport required | Yes (every year) | No (never) |
| Historical years tracked | 4 max | Unlimited |
| Filter logic complexity (organismes_controller) | 19 lines, 2 params | ~3 lines, 1 param |
| Form radio button groups | 4 groups × 2 options | 1 toggle + 1 year field |
| Operateur boolean columns | 4 | 0 (replaced by array) |
| Files modified | — | 15 |

## Product Scope

### MVP - Minimum Viable Product

The entire refactoring plan (12 steps) is delivered as a single atomic change. This is not decomposable because the boolean columns and array column cannot coexist in a functional state.

**MVP includes all of:**
1. Database migration (add `annees[]`, add `operateur_actif`, migrate data, drop booleans)
2. Model layer updates (new helper methods, updated imports, ransackable attributes)
3. Controller updates (CRUD validation, filter simplification, year mapping)
4. View updates (form redesign, show page, index filters)
5. Export updates (XLSX column changes)
6. JavaScript updates (form controller selector changes)
7. Admin panel updates (permitted params)
8. Test updates (fixtures, new model tests)

### Growth Features (Post-MVP)

- **Year range visualization**: Timeline chart showing active/inactive periods per operator
- **Bulk activation/deactivation**: Batch operations for managing multiple operators
- **Historical reporting**: Dedicated report view showing operator status changes over time
- **Audit trail**: Log of all activation/deactivation events with user attribution

### Vision (Future)

- **Predictive analytics**: Trend analysis on operator lifecycle patterns
- **Automated status management**: Rules-based activation/deactivation triggered by external data sources
- **API exposure**: REST endpoint for operator historical data for inter-ministry consumption

## User Journeys

### Journey 1: 2B2O — Activating a New Operator

Navigate to organism show page → edit operator block → toggle "Opérateur actif: Oui" → enter start year → select programme/mission/category → submit. System creates operateur record with `annees: [start_year]`, `operateur_actif: true`. No annual reimport needed.

### Journey 2: 2B2O — Deactivating an Operator from Index

Navigate to operators index → find operator in table → click "Rendre inactif" button → modal opens asking "Année de fin d'activité ?" → enter year → confirm. System expands years array and sets `operateur_actif: false`. Full history preserved.

### Journey 3: 2B2O — Excel Import

Upload standard Excel file (same format: "Opérateur 2025", "Opérateur 2024" columns) → system maps OUI/NON to years → constructs `annees` array → merges with existing historical data. No overwriting of history.

### Journey 4: Contrôleur — Budget Creation

Open organism page → see "Opérateur: Oui (depuis XXXX)" → create budget for fiscal year → system checks `operateur_pour_annee?(year)` dynamically → correct programme association.

### Journey 5: Bureau Sectoriel — Consultation & Export

Filter organisms index by "Opérateur: Oui" (single `operateur_actif` flag) → view list → export XLSX with "Opérateur actif" + "Années opérateur" columns (full history instead of 4-year snapshot).

### Journey 6: Admin — ActiveAdmin

Edit operator records directly with `annees: []` array instead of four boolean columns.

### Journey Requirements Summary

| Journey | Key Capabilities |
|---------|-----------------|
| Activate | Toggle + year input on organism show page |
| Deactivate | Operators index table with "deactivate" button + modal |
| Import | Backward-compatible Excel import with year merging |
| Budget | Year-based operator lookup (`operateur_pour_annee?`) |
| Consult/Export | Simple `operateur_actif` filter, enhanced XLSX with full history |
| Admin | Updated ActiveAdmin params for array model |
