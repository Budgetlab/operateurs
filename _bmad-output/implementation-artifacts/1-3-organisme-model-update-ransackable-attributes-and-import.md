# Story 1.3: Organisme Model — Update ransackable_attributes and Import

Status: done

## Story

As a **developer**,
I want the Organisme model updated to support the new `operateur_actif` field and adapted Excel import,
So that filtering and data import work correctly with the new data model.

## Acceptance Criteria

1. **Given** the Organisme model
   **When** `ransackable_attributes` is called
   **Then** `"operateur_actif"` is included in the list

2. **Given** an Excel file with columns "Opérateur 2025", "Opérateur 2024", etc. (same format as current)
   **When** `Organisme.import(file)` is called
   **Then** the OUI/NON values are converted to years and stored in the operateur's `annees` array
   **And** `operateur_actif` on the organism is set to `true` if any current/future year is OUI
   **And** existing historical years in `annees` are preserved (not overwritten)

## Tasks / Subtasks

- [x] Task 1: Add `"operateur_actif"` to Organisme.ransackable_attributes (AC: #1)
  - [x] 1.1: Already done in story 1.1 — verified by test

- [x] Task 2: Update `Organisme.import` method (AC: #2)
  - [x] 2.1: Replace lines 104-108 (boolean assignments) with year-based logic
  - [x] 2.2: Map Excel columns to years: "Opérateur 2025" → 2025, "Opérateur 2024" → 2024, etc.
  - [x] 2.3: Build `annees` array from OUI values, merge with existing years
  - [x] 2.4: Set `operateur_actif` based on whether any current/future year is active
  - [x] 2.5: Handle Programme chef file = 'N/A' case (destroy operateur — existing behavior)

## Dev Notes

### File to Modify

**`app/models/organisme.rb`** — 159 lines [Source: app/models/organisme.rb]

### Current Import Logic (lines 98-121)

```ruby
if row_data['Programme chef file'] == 'N/A'
  organisme.operateur&.destroy
else
  operateur = Operateur.find_or_initialize_by(organisme_id: organisme.id)
  # ... programme/mission lookup ...
  operateur.assign_attributes(
    operateur_nf: convert_to_boolean(row_data['Opérateur 2025']),  # line 105
    operateur_n: convert_to_boolean(row_data['Opérateur 2024']),   # line 106
    operateur_n1: convert_to_boolean(row_data['Opérateur 2023']),  # line 107
    operateur_n2: convert_to_boolean(row_data['Opérateur 2022']),  # line 108
    presence_categorie: convert_to_boolean(row_data['Appartenance catégorie opérateurs']),
    nom_categorie: convert_to_boolean(row_data['Nom catégorie']),
    programme_id: programme_id,
    mission_id: mission_id,
  )
  operateur.save if operateur.changed?
  # ... operateur_programmes handling ...
end
```

### New Import Logic

Replace lines 104-113 with:

```ruby
# Build annees from Excel columns
year_columns = {
  'Opérateur 2025' => 2025,
  'Opérateur 2024' => 2024,
  'Opérateur 2023' => 2023,
  'Opérateur 2022' => 2022
}
new_years = year_columns.select { |col, _| convert_to_boolean(row_data[col]) == true }.values
existing_years = operateur.annees || []
merged_years = (existing_years + new_years).uniq.sort

# Determine if currently active (any current/future year)
current_year = Date.today.year
is_active = new_years.any? { |y| y >= current_year }

operateur.assign_attributes(
  annees: merged_years,
  presence_categorie: convert_to_boolean(row_data['Appartenance catégorie opérateurs']),
  nom_categorie: convert_to_boolean(row_data['Nom catégorie']),
  programme_id: programme_id,
  mission_id: mission_id,
)
operateur.save if operateur.changed?
organisme.update(operateur_actif: is_active)
```

### Excel Column Names

**CRITICAL:** The Excel column names are hardcoded with specific years:
- Current file: "Opérateur 2025", "Opérateur 2024", "Opérateur 2023", "Opérateur 2022"
- These will change with each annual import cycle
- The year-to-column mapping must match the actual Excel headers

### Ransackable Attributes

Current (line 143-144): Long array ending with `"updated_at"]`
Add `"operateur_actif"` after the existing attributes.

### CRITICAL WARNINGS

1. **Excel column names contain HARDCODED years** — "Opérateur 2025", "Opérateur 2024", etc. These change annually. Consider extracting years from column headers dynamically.
2. **Preserve the `Programme chef file == 'N/A'` destroy logic** (line 98-99) — this stays unchanged
3. **Merge years, don't overwrite** — `(existing_years + new_years).uniq.sort` preserves history
4. **Also update `Operateur.import`** — see the Operateur model's own import method (lines 10-47). It also references boolean columns on line 21 and lines 23-27.
5. **`convert_to_boolean` returns `true`, `false`, or `nil`** — check for `== true` specifically

### Operateur.import Also Needs Updating

The `Operateur.import` method (lines 10-47 in operateur.rb) also imports from Excel:
- Line 21: `[row_data['operateur_n'], row_data['operateur_n1'], row_data['operateur_n2']].any?('OUI')`
- Lines 23-26: Sets boolean columns via `convert_to_boolean`

This must also be updated to build `annees` arrays. The column names differ from Organisme.import — they use lowercase without year numbers: `operateur_n`, `operateur_n1`, `operateur_n2`.

### References

- [Source: `app/models/organisme.rb` lines 98-121] — Current import with boolean assignments
- [Source: `app/models/organisme.rb` line 143-144] — Ransackable attributes
- [Source: `app/models/operateur.rb` lines 10-47] — Operateur.import method
- [Source: `docs/plan-refactoring-operateur.md` lines 45-50] — Étape 3 spec

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6 (Amelia, Dev Agent)

### Debug Log References

- Tests initially used hardcoded years (2024, 2025) which are both past in 2026 — fixed to use `Date.today.year` dynamically in test data.
- `call_import_row` helper uses dynamic regex extraction of year columns (`/\AOpérateur \d{4}\z/`) so tests don't depend on hardcoded year list.

### Completion Notes List

- Task 1 (ransackable_attributes): already complete from story 1.1 — confirmed by test ✅
- `Organisme.import`: replaced `operateur_nf/n/n1/n2` assignments with `year_columns` hash mapping → `annees` merge logic; `organisme.update(operateur_actif:)` added
- `Operateur.import`: replaced `any?('OUI')` boolean check + column assignments with `year_map` hash; sets `annees` + `organisme.operateur_actif`
- Tests: 4 integration-style unit tests covering OUI/active, OUI/inactive, merge preservation, N/A destroy
- 29 tests, 67 assertions, 0 failures ✅

### File List

- `app/models/organisme.rb` (modified — import method updated with dynamic year extraction)
- `app/models/operateur.rb` (modified — import method updated with dynamic year mapping)
- `test/models/organisme_test.rb` (populated with 5 unit tests)

### Change Log

- 2026-02-24: Story 1.3 implemented — Organisme.import and Operateur.import updated to year-based annees logic
- 2026-02-24: Code review (Amelia/claude-opus-4-6) — Fixed: (H1) Organisme.import year_columns hardcoded with stale years — replaced with dynamic regex extraction from row headers; (H2) Operateur.import year_map hardcoded 2026 — replaced with Date.today.year-based dynamic mapping; (M1) Tests now use identical regex extraction logic as production code; (M3) operateur_actif update now conditional on successful operateur.save in both imports; (L1) Removed task-reference comments from tests. Also found and fixed missing organisme.update(operateur_actif:) in Operateur.import that had been dropped during refactoring.
