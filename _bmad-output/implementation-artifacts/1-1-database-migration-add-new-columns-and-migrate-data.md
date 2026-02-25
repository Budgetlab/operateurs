# Story 1.1: Database Migration — Add New Columns and Migrate Data

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **developer**,
I want to migrate the database schema from four boolean columns to an `annees integer[]` array on `operateurs` and add `operateur_actif boolean` on `organismes`,
So that the data model supports lifecycle-based operator tracking with full historical data preserved.

## Acceptance Criteria

1. **Given** the current database with `operateur_nf`, `operateur_n`, `operateur_n1`, `operateur_n2` boolean columns on `operateurs`
   **When** the migration runs
   **Then** a new `annees integer[]` column with `default: []` is added to `operateurs`

2. **Given** the organismes table
   **When** the migration runs
   **Then** a new `operateur_actif boolean` column with `default: false` is added to `organismes`

3. **Given** existing operateur records with boolean data
   **When** data migration runs
   **Then** boolean values are mapped to years: `operateur_nf`→2027, `operateur_n`→2026, `operateur_n1`→2025, `operateur_n2`→2024

4. **Given** an operateur with `operateur_n: true` OR `operateur_nf: true` (active in current or future year)
   **When** data migration runs
   **Then** `operateur_actif` is set to `true` on the associated organisme
   **And** `annees` stores only the first year of the current contiguous active range (e.g., if n2=true, n1=true, n=true, nf=true → `annees: [2024]`)

5. **Given** an operateur with only past-year booleans true (n1 and/or n2, but NOT n and NOT nf)
   **When** data migration runs
   **Then** `operateur_actif` is set to `false` on the associated organisme
   **And** `annees` stores all individual years where booleans were true (e.g., n1=true, n2=true → `annees: [2024, 2025]`)

6. **Given** an operateur with non-contiguous active years (e.g., n2=true, n1=false, n=true)
   **When** data migration runs
   **Then** the gap is handled: past segment stored as individual years, current segment stored as start year
   **And** `operateur_actif` is set to `true` (because n or nf is true)

7. **Given** the migration has completed
   **When** schema is inspected
   **Then** the four boolean columns (`operateur_nf`, `operateur_n`, `operateur_n1`, `operateur_n2`) are dropped
   **And** a GIN index exists on `operateurs.annees`

8. **Given** the migration has run
   **When** `rails db:rollback` is executed
   **Then** the migration is reversible: boolean columns are restored and `annees`/`operateur_actif` are removed

9. **Given** all operateur records pre-migration
   **When** data migration completes
   **Then** zero data loss is verified — every operateur has correct year data matching original boolean states

10. **Given** the updated test fixtures
    **When** `rails test` is run
    **Then** fixtures use `annees: [2025, 2026]` format instead of boolean fields
    **And** all existing tests pass without regression

## Tasks / Subtasks

- [x] Task 1: Create the migration file (AC: #1, #2, #3, #4, #5, #6, #7, #8)
  - [x] 1.1: Add `annees integer[], default: []` column to `operateurs`
  - [x] 1.2: Add `operateur_actif boolean, default: false` column to `organismes`
  - [x] 1.3: Write data migration logic with year mapping (nf→2027, n→2026, n1→2025, n2→2024)
  - [x] 1.4: Handle active operators (n or nf true): store only start year of contiguous range, set `operateur_actif: true`
  - [x] 1.5: Handle inactive operators (only n1/n2 true): store all individual years, set `operateur_actif: false`
  - [x] 1.6: Handle edge cases (non-contiguous years, all false, all true)
  - [x] 1.7: Drop the 4 boolean columns
  - [x] 1.8: Add GIN index on `operateurs.annees`
  - [x] 1.9: Write reversible `down` method restoring boolean columns from `annees` data

- [x] Task 2: Update test fixtures (AC: #10)
  - [x] 2.1: Update `test/fixtures/operateurs.yml` — replace `operateur_n`/`n1`/`n2` with `annees` arrays
  - [x] 2.2: Add `operateur_actif: true/false` to `test/fixtures/organismes.yml` if needed

- [x] Task 3: Update Operateur model ransackable_attributes (AC: #9)
  - [x] 3.1: Remove `"operateur_n"`, `"operateur_n1"`, `"operateur_n2"`, `"operateur_nf"` from `ransackable_attributes`
  - [x] 3.2: Add `"annees"` to `ransackable_attributes`

- [x] Task 4: Update Organisme model ransackable_attributes
  - [x] 4.1: Add `"operateur_actif"` to `Organisme.ransackable_attributes`

- [x] Task 5: Verify migration (AC: #9)
  - [x] 5.1: Run `rails db:migrate` and verify schema changes
  - [x] 5.2: Spot-check data: active operators have correct annees + operateur_actif
  - [x] 5.3: Spot-check data: inactive operators have correct annees + operateur_actif
  - [x] 5.4: Run `rails db:rollback` and verify reversibility
  - [x] 5.5: Re-run migration and confirm `rails test` passes

## Dev Notes

### Migration Data Logic — CRITICAL

The migration must handle the conceptual shift from "snapshot" to "lifecycle" model. The key algorithm:

```ruby
# For each operateur record:
year_map = { operateur_nf: 2027, operateur_n: 2026, operateur_n1: 2025, operateur_n2: 2024 }
true_years = year_map.select { |col, _| record[col] == true }.values.sort

if record[:operateur_n] == true || record[:operateur_nf] == true
  # ACTIVE operator — store only start of current contiguous range
  # Find contiguous range that includes current/future year (2026 or 2027)
  # Example: [2024, 2025, 2026, 2027] → annees: [2024] (start of range)
  # Example: [2025, 2027] → annees: [2025, 2027] (gap breaks contiguity — 2025 is past, 2027 is start)
  # Actually: need to identify the contiguous block touching n/nf and store its start
  operateur_actif = true
else
  # INACTIVE operator — store all individual years
  # Example: [2024, 2025] → annees: [2024, 2025]
  operateur_actif = false
end
```

**Edge case: non-contiguous with gap.** Example: n2=true (2024), n1=false, n=true (2026), nf=true (2027).
- The "active contiguous range" touching current year is [2026, 2027], start = 2026
- The past disconnected year 2024 stays as individual year
- Result: `annees: [2024, 2026]`, `operateur_actif: true`
- Interpretation: was operator in 2024, inactive in 2025, reactivated in 2026-present

**Edge case: all false.** No operateur record should exist if all are false (the controller destroys it), but if found: `annees: []`, `operateur_actif: false`.

### Current Database Schema — operateurs table

[Source: `db/schema.rb` lines 246-261]

```
operateurs:
  - id (bigint, PK)
  - organisme_id (bigint, FK, not null)
  - mission_id (bigint, FK, not null)
  - programme_id (bigint, FK, not null)
  - operateur_nf (boolean)     ← DROP
  - operateur_n (boolean)      ← DROP
  - operateur_n1 (boolean)     ← DROP
  - operateur_n2 (boolean)     ← DROP
  - presence_categorie (boolean)  — KEEP
  - nom_categorie (string)        — KEEP
  - created_at, updated_at
```

Indexes: mission_id, organisme_id, programme_id. **ADD:** GIN index on `annees`.

### Current Operateur Model

[Source: `app/models/operateur.rb` lines 1-68]

- `belongs_to :organisme`, `belongs_to :mission`, `belongs_to :programme`
- `has_many :operateur_programmes, dependent: :destroy`
- `ransackable_attributes` includes the 4 booleans (line 63) — must update
- `import` method (lines 10-47) — NOT modified in this story (Story 4.3 handles import)
- **NOTE:** `operateur_nf` is NOT checked in `import` method line 21 — only n, n1, n2. This is existing behavior.

### Current Test Fixtures

[Source: `test/fixtures/operateurs.yml`]

- Two fixtures: `one` and `two`, both with `operateur_n: false`, `operateur_n1: false`, `operateur_n2: false`
- **Missing:** `operateur_nf` is absent from fixtures (bug in existing fixtures)
- After migration: replace with `annees: []` (since all booleans are false, empty array is correct)

### Current Test File

[Source: `test/models/operateur_test.rb`]

- Empty — no existing tests. New tests for lifecycle methods are in Story 1.2, not this story.
- This story only needs fixtures to be valid for existing tests to pass.

### Organisme Model — Key Relationship

[Source: `app/models/organisme.rb` line 11]

- `has_one :operateur, dependent: :destroy`
- `ransackable_attributes` (line 143) — must add `"operateur_actif"`
- `ransackable_associations` includes `"operateur"` (line 148) — used for nested Ransack queries

### Project Structure Notes

- Rails migration naming: `db/migrate/YYYYMMDDHHMMSS_refactor_operateur_annees.rb`
- PostgreSQL array columns supported natively in Rails: `t.integer :annees, array: true, default: []`
- GIN index for array: `add_index :operateurs, :annees, using: :gin`
- Project uses PostgreSQL with `unaccent` extension already enabled
- Reversible migration pattern: use `reversible do |dir|` block

### CRITICAL WARNINGS FOR DEV AGENT

1. **DO NOT modify the import methods** — those are Story 1.3 and 4.3. Only modify ransackable_attributes in this story.
2. **DO NOT modify controllers** — those are later stories (Epic 2-5).
3. **DO NOT modify views or JavaScript** — those are later stories.
4. **Fixtures must be valid** — after dropping boolean columns, fixtures referencing them will break tests. Update fixtures FIRST or in the same commit.
5. **The `operateur_actif` column goes on `organismes` table**, NOT on `operateurs`. This is a denormalized flag for fast filtering.
6. **Year mapping is HARDCODED** for this migration cycle: nf=2027, n=2026, n1=2025, n2=2024. These values are specific to the current data and won't change.
7. **Test with `rails test`** after migration to ensure no regressions.

### References

- [Source: `docs/plan-refactoring-operateur.md` — Étape 1, lines 16-28] — Authoritative migration spec
- [Source: `_bmad-output/planning-artifacts/epics.md` — Story 1.1, lines 104-123] — Acceptance criteria
- [Source: `_bmad-output/planning-artifacts/prd.md` — Technical Success section] — Zero data loss requirement
- [Source: `docs/data-models.md` lines 170-185] — Current operateurs table spec
- [Source: `docs/architecture.md` lines 9-25] — Technology stack (Rails 8.1, PostgreSQL)
- [Source: `db/schema.rb` lines 246-261] — Current operateurs schema
- [Source: `db/schema.rb` lines 281-335] — Current organismes schema
- [Source: `app/models/operateur.rb` lines 62-64] — Current ransackable_attributes
- [Source: `app/models/organisme.rb` line 143] — Organisme ransackable_attributes
- [Source: `test/fixtures/operateurs.yml`] — Current fixture format

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6 (Amelia, Dev Agent)

### Debug Log References

No blockers encountered.

### Completion Notes List

- Migration `20260224172059_refactor_operateur_annees.rb` created with PL/pgSQL for complex contiguous-range data migration logic
- Handles all AC scenarios: active (n/nf), inactive (only n1/n2), non-contiguous, all-false edge cases
- `down` method restores boolean columns using PL/pgSQL with contiguous-range expansion for active operators
- Fixtures updated: `operateurs.yml` uses `annees: []`, `organismes.yml` adds `operateur_actif: false`
- `Operateur.ransackable_attributes`: removed 4 boolean columns, added `"annees"`
- `Organisme.ransackable_attributes`: added `"operateur_actif"`
- Migration ran successfully, rollback verified, re-migration verified
- 11 tests, 22 assertions, 0 failures ✅

### File List

- `db/migrate/20260224172059_refactor_operateur_annees.rb` (new)
- `db/schema.rb` (auto-generated by migration)
- `test/fixtures/operateurs.yml` (modified)
- `test/fixtures/organismes.yml` (modified)
- `app/models/operateur.rb` (modified — ransackable_attributes)
- `app/models/organisme.rb` (modified — ransackable_attributes)

### Change Log

- 2026-02-24: Story 1.1 implemented — database migration, fixture updates, ransackable_attributes cleanup
- 2026-02-24: Code review (Amelia/claude-opus-4-6) — Fixed lossy rollback in `down` method: active operators with contiguous-range start years now correctly expand back to individual boolean columns using PL/pgSQL. Added `db/schema.rb` to File List. Noted 8 CRITICAL findings (broken controllers/views/admin/imports referencing dropped boolean columns) as intentionally deferred to stories 1.2-5.x per story Dev Notes.
