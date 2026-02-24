---
stepsCompleted:
  - step-01-validate-prerequisites
  - step-02-design-epics
  - step-03-create-stories
  - step-04-final-validation
inputDocuments:
  - _bmad-output/planning-artifacts/prd.md
  - docs/plan-refactoring-operateur.md
  - docs/architecture.md
  - docs/data-models.md
---

# Operateurs Refactoring - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for the Operateurs Refactoring feature, decomposing the requirements from the PRD and technical refactoring plan into implementable stories. The refactoring replaces four boolean columns (`operateur_nf`, `operateur_n`, `operateur_n1`, `operateur_n2`) with an `annees integer[]` array on `operateurs` and an `operateur_actif boolean` on `organismes`, shifting from snapshot-based to lifecycle-based operator tracking.

## Requirements Inventory

### Functional Requirements

- FR1: Replace four boolean columns (`operateur_nf`, `operateur_n`, `operateur_n1`, `operateur_n2`) with `annees integer[]` on `operateurs` table
- FR2: Add `operateur_actif boolean` on `organismes` table to quickly identify if an organism is an operator — enables simple filtering on organisms index (`operateur_actif_in`) without joining through `operateurs` table
- FR3: Migrate existing data: map nf→2027, n→2026, n1→2025, n2→2024 into `annees` array with correct active/inactive logic
- FR4: Provide `operateur_pour_annee?(year)` method for year-based operator status lookup
- FR5: Provide `toutes_annees` method returning all years (expanding active range dynamically)
- FR6: Provide `activer!(annee)` and `desactiver!(annee_fin)` lifecycle methods
- FR7: Update operateur form: replace 4 radio button groups with toggle Oui/Non + year input field
- FR8: Enable operator block editing directly from organism show page
- FR9: Update operators index page with table view + "Rendre inactif" button that opens modal asking for end year
- FR10: Simplify organism index filtering: replace complex `operateur_n_in`/`operateur_n_null` logic with single `operateur_actif_in` filter
- FR11: Update `select_exercice` in chiffres controller to use `operateur_pour_annee?(year)` instead of case/when on booleans
- FR12: Update XLSX exports (index + show) to use "Opérateur actif" + "Années opérateur" columns instead of 4 year columns
- FR13: Keep Excel import format unchanged; adapt server-side to construct `annees` array from Excel columns
- FR14: Update ActiveAdmin permitted params
- FR15: Update organism show page: display "Opérateur: Oui (depuis XXXX)" or "Non" with year history

### NonFunctional Requirements

- NFR1: Zero data loss during migration — all existing boolean data must be correctly converted
- NFR2: Migration must be reversible (rollback capability)
- NFR3: Performance parity — page load times unchanged, GIN index on `annees`
- NFR4: All existing tests pass without regression
- NFR5: DSFR design system compliance for new UI elements (toggle, modal)
- NFR6: Accessibility compliance (RGAA) for form changes

### Additional Requirements

- Drop the 4 boolean columns after data migration
- Update `ransackable_attributes` in both Operateur and Organisme models
- Update JavaScript `ChangeOperateur()` selectors in form_controller.js
- Update test fixtures and add new model tests for lifecycle methods

### FR Coverage Map

| FR | Epic | Description |
|----|------|-------------|
| FR1 | Epic 1 | Replace booleans with `annees[]` |
| FR2 | Epic 1 | Add `operateur_actif` on organismes |
| FR3 | Epic 1 | Migrate existing data |
| FR4 | Epic 1 | `operateur_pour_annee?` method |
| FR5 | Epic 1 | `toutes_annees` method |
| FR6 | Epic 1 | `activer!` / `desactiver!` methods |
| FR7 | Epic 2 | New form with toggle + year |
| FR8 | Epic 2 | Edit operator from organism show |
| FR9 | Epic 3 | Operators index + deactivation modal |
| FR10 | Epic 4 | Simplified organism filtering |
| FR11 | Epic 4 | Budget `select_exercice` update |
| FR12 | Epic 5 | XLSX export updates |
| FR13 | Epic 4 | Excel import adaptation |
| FR14 | Epic 5 | ActiveAdmin params update |
| FR15 | Epic 2 | Organism show page display |

## Epic List

### Epic 1: Data Model Migration & Core Lifecycle Methods
Establish the new `annees[]` array data model and lifecycle methods so that operator status is tracked through activation/deactivation periods instead of annual boolean snapshots.
**FRs covered:** FR1, FR2, FR3, FR4, FR5, FR6

### Epic 2: Operator Management UI (Forms & Show Page)
Users (2B2O, Contrôleurs) can activate/deactivate operators through a simplified form with toggle + year input, directly from the organism show page.
**FRs covered:** FR7, FR8, FR15

### Epic 3: Operators Index & Batch Deactivation
2B2O can view all operators in a table and quickly deactivate any operator via a modal dialog asking for the end year.
**FRs covered:** FR9

### Epic 4: Filtering, Budget Integration & Import
All users benefit from simplified filtering, correct budget association, and backward-compatible Excel import that preserves historical data.
**FRs covered:** FR10, FR11, FR13

### Epic 5: Exports, Admin & Cleanup
XLSX exports reflect the new data model, ActiveAdmin is updated, and old boolean columns are dropped.
**FRs covered:** FR12, FR14

---

## Epic 1: Data Model Migration & Core Lifecycle Methods

Establish the new `annees[]` array data model and lifecycle methods so that operator status is tracked through activation/deactivation periods instead of annual boolean snapshots.

### Story 1.1: Database Migration — Add New Columns and Migrate Data

As a **developer**,
I want to migrate the database schema from four boolean columns to an `annees integer[]` array on `operateurs` and add `operateur_actif boolean` on `organismes`,
So that the data model supports lifecycle-based operator tracking with full historical data preserved.

**Acceptance Criteria:**

**Given** the current database with `operateur_nf`, `operateur_n`, `operateur_n1`, `operateur_n2` boolean columns on `operateurs`
**When** the migration runs
**Then** a new `annees integer[]` column with `default: []` is added to `operateurs`
**And** a new `operateur_actif boolean` column with `default: false` is added to `organismes`
**And** existing data is migrated: nf→2027, n→2026, n1→2025, n2→2024 mapped into the `annees` array
**And** organisms with `operateur_n == true` or `operateur_nf == true` have `operateur_actif` set to `true`
**And** active operators store only the first year of the current contiguous active range
**And** inactive operators store all individual years where booleans were true
**And** the four boolean columns are dropped
**And** a GIN index is added on `annees`
**And** the migration is reversible (rollback restores boolean columns)
**And** zero data loss is verified — all operators have correct year data post-migration

### Story 1.2: Operateur Model — Lifecycle Methods and Year Queries

As a **developer**,
I want helper methods on the Operateur model for year-based queries and lifecycle management,
So that all code can use clean, consistent methods instead of checking individual boolean columns.

**Acceptance Criteria:**

**Given** an Operateur record with `annees: [2024]` and `organisme.operateur_actif: true`
**When** calling `toutes_annees`
**Then** it returns all years from 2024 to the current year (dynamically expanded)

**Given** an Operateur with `annees: [2022, 2023, 2024]` and `operateur_actif: false`
**When** calling `toutes_annees`
**Then** it returns `[2022, 2023, 2024]` (no expansion)

**Given** any Operateur
**When** calling `operateur_pour_annee?(2025)`
**Then** it returns `true` if 2025 is in the resolved years, `false` otherwise

**Given** an organism and a year
**When** calling `activer!(2026)`
**Then** the year is added to `annees`, `operateur_actif` is set to `true` on the organism

**Given** an active operator
**When** calling `desactiver!(2027)`
**Then** all years from start to 2027 are expanded into `annees` and `operateur_actif` is set to `false`

**And** `ransackable_attributes` is updated: four booleans removed, `annees` added
**And** unit tests cover all methods: `operateur_pour_annee?`, `toutes_annees`, `activer!`, `desactiver!`
**And** test fixtures are updated: booleans replaced with `annees` arrays

### Story 1.3: Organisme Model — Update ransackable_attributes and Import

As a **developer**,
I want the Organisme model updated to support the new `operateur_actif` field and adapted Excel import,
So that filtering and data import work correctly with the new data model.

**Acceptance Criteria:**

**Given** the Organisme model
**When** `ransackable_attributes` is called
**Then** `"operateur_actif"` is included in the list

**Given** an Excel file with columns "Opérateur 2025", "Opérateur 2024", etc. (same format as current)
**When** `Organisme.import(file)` is called
**Then** the OUI/NON values are converted to years and stored in the operateur's `annees` array
**And** `operateur_actif` on the organism is set to `true` if any current/future year is OUI
**And** existing historical years in `annees` are preserved (not overwritten)

---

## Epic 2: Operator Management UI (Forms & Show Page)

Users (2B2O, Contrôleurs) can activate/deactivate operators through a simplified form with toggle + year input, directly from the organism show page.

### Story 2.1: Operateur Form — Replace Radio Buttons with Toggle and Year Input

As a **2B2O administrator**,
I want the operator form to show a simple toggle "Opérateur actif: Oui/Non" and a year input "Opérateur depuis (année)" instead of four radio button groups,
So that activating or deactivating an operator is simpler and more intuitive.

**Acceptance Criteria:**

**Given** the operator form (`app/views/operateurs/_form.html.erb`)
**When** the form is displayed
**Then** a DSFR-compliant toggle replaces the four radio button groups (lines 29-108)
**And** a numeric year input field "Opérateur depuis (année)" is shown when toggle is "Oui"
**And** the category, programme, and mission fields remain and are enabled/disabled based on toggle state

**Given** the JavaScript form controller (`form_controller.js`)
**When** `ChangeOperateur()` is triggered
**Then** it checks the new toggle element (`#radio-operateur-actif-1`) instead of `[id^="radio-operateurn"]`
**And** category, programme, mission, and linked programs are enabled/disabled based on toggle state

**Given** the operateurs controller
**When** creating an operator with toggle "Oui" and year "2026"
**Then** the operator is saved with `annees: [2026]` and `operateur_actif: true` on the organism

**Given** the operateurs controller
**When** updating an operator with toggle "Non"
**Then** `desactiver!` is called instead of destroying the record
**And** `operateur_params` permits `:operateur_actif`, `:annee_debut` instead of the four booleans

### Story 2.2: Organism Show Page — Display Operator Status and Enable Editing

As a **2B2O administrator or Contrôleur**,
I want the organism show page to display "Opérateur: Oui (depuis XXXX)" with year history, and allow editing the operator block directly,
So that I can see and manage operator status without navigating to a separate page.

**Acceptance Criteria:**

**Given** an organism that is an active operator since 2024
**When** viewing the organism show page (`app/views/organismes/show.html.erb`)
**Then** the operator section displays "Opérateur: Oui (depuis 2024)" instead of four separate year lines
**And** if there is historical data (e.g., inactive periods), the year list is shown

**Given** an organism that is not an operator
**When** viewing the organism show page
**Then** the operator section displays "Opérateur: Non"

**Given** a 2B2O user viewing the organism show page
**When** they click an edit action on the operator block
**Then** they can modify the operator status directly from the show page (via the operator form or inline editing)
**And** the category, mission, programme, and linked programs fields remain displayed as before

---

## Epic 3: Operators Index & Batch Deactivation

2B2O can view all operators in a table and quickly deactivate any operator via a modal dialog asking for the end year.

### Story 3.1: Operators Index — Table View with Deactivation Modal

As a **2B2O administrator**,
I want the operators index page to display a table of all operators with their status, and a "Rendre inactif" button that opens a modal asking for the end year,
So that I can quickly see all operators and deactivate any of them without navigating to individual pages.

**Acceptance Criteria:**

**Given** the operators index page (`/opera/operateurs`)
**When** a 2B2O user navigates to it
**Then** a DSFR-compliant table is displayed with columns: Organisme, Programme, Mission, Catégorie, Statut (Actif/Inactif), Années
**And** active operators show a "Rendre inactif" button
**And** inactive operators show their year range without the button

**Given** an active operator in the table
**When** the user clicks "Rendre inactif"
**Then** a DSFR modal dialog opens with: a year input field "Inactif depuis (année)", a "Confirmer" button, and a "Annuler" button

**Given** the deactivation modal is open
**When** the user enters year "2027" and clicks "Confirmer"
**Then** `desactiver!(2027)` is called on the operator
**And** the operator's `annees` array is expanded (all years from start to 2027)
**And** `operateur_actif` on the organism is set to `false`
**And** the table row updates to reflect "Inactif" status
**And** a success flash message is displayed

**Given** the deactivation modal is open
**When** the user clicks "Annuler"
**Then** the modal closes without any changes

---

## Epic 4: Filtering, Budget Integration & Import

All users benefit from simplified filtering, correct budget association, and backward-compatible Excel import that preserves historical data.

### Story 4.1: Organism Index Filtering — Simplify to operateur_actif

As a **user (any role)**,
I want the organism index page filter to use a simple "Opérateur: Oui/Non" filter instead of the complex multi-param logic,
So that filtering organisms by operator status is intuitive and reliable.

**Acceptance Criteria:**

**Given** the organismes controller (`organismes_controller.rb` lines 28-46)
**When** the complex `operateur_operateur_n_in` / `operateur_operateur_n_null` filter logic is replaced
**Then** a single `operateur_actif_in` filter on the `organismes` table is used
**And** the 19 lines of special-case logic are reduced to ~3 lines

**Given** the organisms index view (`index.html.erb` lines 62-80)
**When** the filter section is rendered
**Then** a simple DSFR tag group "Opérateur: Oui / Non" replaces the complex radio buttons
**And** `q_params` permits `operateur_actif_in: []` instead of `:operateur_operateur_n_in` and `:operateur_operateur_n_null`

**Given** a user selects "Opérateur: Oui"
**When** the filter is applied
**Then** only organisms with `operateur_actif == true` are shown
**And** the filter works consistently across all roles (2B2O, Contrôleur, Bureau Sectoriel)

### Story 4.2: Budget Integration — Year-Based Operator Lookup in Chiffres

As a **Contrôleur**,
I want the budget creation process to correctly detect operator status for any fiscal year using the new year-based model,
So that operator programme association works correctly regardless of the fiscal year.

**Acceptance Criteria:**

**Given** the chiffres controller `select_exercice` method (`chiffres_controller.rb` lines 67-84)
**When** it needs to determine if an organism is an operator for a given fiscal year
**Then** it calls `operateur&.operateur_pour_annee?(date.to_i)` instead of the `case/when` block checking individual booleans
**And** the method works for any year (not limited to 4 hardcoded years)

**Given** an organism that is an active operator since 2024
**When** creating a budget for fiscal year 2028
**Then** `operateur_pour_annee?(2028)` returns `true` (dynamically expanded from active range)
**And** the budget is correctly associated with the operator's programme

### Story 4.3: Excel Import Adaptation — Backward-Compatible Year Array Construction

As a **2B2O administrator**,
I want to continue importing operator data from the same Excel format while the system builds the `annees` array server-side,
So that the import process is unchanged from my perspective but the data is stored in the new format.

**Acceptance Criteria:**

**Given** the Operateur model `import` method (`operateur.rb` lines 10-47)
**When** an Excel file with "Opérateur N", "Opérateur N1", "Opérateur N2" columns (OUI/NON) is imported
**Then** the OUI values are mapped to their corresponding years and stored in the `annees` array
**And** if the operator already exists, imported years are merged with existing `annees` (not overwritten)
**And** `operateur_actif` on the organism is updated based on whether any current/future year is active

**Given** the Organisme model `import` method (`organisme.rb` lines 104-113)
**When** an Excel file with "Opérateur 2025", "Opérateur 2024" columns is imported
**Then** the boolean-to-year mapping constructs the `annees` array correctly
**And** `operateur_actif` is set based on the imported data

---

## Epic 5: Exports, Admin & Cleanup

XLSX exports reflect the new data model, ActiveAdmin is updated, and old boolean columns are dropped.

### Story 5.1: XLSX Exports — Update Columns for New Data Model

As a **user (any role)**,
I want the XLSX exports to show "Opérateur actif" and "Années opérateur" columns instead of four separate year columns,
So that exports contain richer historical data in a cleaner format.

**Acceptance Criteria:**

**Given** the organisms index XLSX export (`index.xlsx.axlsx`)
**When** an export is generated
**Then** the four columns "Opérateur YYYY" are replaced by two columns: "Opérateur actif" (Oui/Non) and "Années opérateur" (comma-separated list)
**And** active operators show all dynamically expanded years (e.g., "2022, 2023, 2024, 2025, 2026")
**And** the total column count is adjusted (57→55) and style ranges updated accordingly

**Given** the organism show XLSX export (`show.xlsx.axlsx`)
**When** an export is generated
**Then** the same column changes are applied as in the index export
**And** the `array_operateur` construction uses `organisme.operateur_actif` and `operateur.toutes_annees.join(', ')`

### Story 5.2: ActiveAdmin & Final Cleanup

As an **admin user**,
I want ActiveAdmin to work with the new data model, and all legacy boolean references to be removed from the codebase,
So that the codebase is clean with no references to the old four-boolean model.

**Acceptance Criteria:**

**Given** the ActiveAdmin operateurs resource (`app/admin/operateurs.rb`)
**When** the admin panel is loaded
**Then** `permit_params` includes `annees: []` instead of the four boolean columns

**Given** the complete codebase
**When** searching for references to `operateur_nf`, `operateur_n`, `operateur_n1`, `operateur_n2`
**Then** zero references are found (all have been replaced)

**And** test fixtures (`test/fixtures/operateurs.yml`) use `annees: [2023, 2024]` instead of boolean fields
**And** all existing tests pass (`rails test`)
**And** new model tests exist for `operateur_pour_annee?`, `toutes_annees`, `activer!`, `desactiver!`
