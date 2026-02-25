# Story 1.2: Operateur Model — Lifecycle Methods and Year Queries

Status: done

## Story

As a **developer**,
I want helper methods on the Operateur model for year-based queries and lifecycle management,
So that all code can use clean, consistent methods instead of checking individual boolean columns.

## Acceptance Criteria

1. **Given** an Operateur with `annees: [2024]` and `organisme.operateur_actif: true`
   **When** calling `toutes_annees`
   **Then** it returns all years from 2024 to the current year (dynamically expanded): `[2024, 2025, 2026]`

2. **Given** an Operateur with `annees: [2022, 2023, 2024]` and `operateur_actif: false`
   **When** calling `toutes_annees`
   **Then** it returns `[2022, 2023, 2024]` (no expansion — inactive means all years are already stored)

3. **Given** an Operateur with gap: `annees: [2018, 2019, 2024]` and `operateur_actif: true`
   **When** calling `toutes_annees`
   **Then** it returns `[2018, 2019, 2024, 2025, 2026]` (past years as-is, active range expanded from 2024)

4. **Given** any Operateur
   **When** calling `operateur_pour_annee?(2025)`
   **Then** it returns `true` if 2025 is in the resolved `toutes_annees`, `false` otherwise

5. **Given** an organism and a year
   **When** calling `activer!(2026)`
   **Then** `2026` is added to `annees`, `operateur_actif` is set to `true` on the organism, and the record is saved

6. **Given** an active operator (annees: [2024], operateur_actif: true)
   **When** calling `desactiver!(2027)`
   **Then** all years from the active start to 2027 are expanded into `annees` (e.g., `[2024, 2025, 2026, 2027]`)
   **And** `operateur_actif` is set to `false` on the organism
   **And** the record is saved

7. **Given** the updated Operateur model
   **When** `ransackable_attributes` is called
   **Then** `"operateur_n"`, `"operateur_n1"`, `"operateur_n2"`, `"operateur_nf"` are removed
   **And** `"annees"` is present

8. **Given** the test suite
   **When** `rails test test/models/operateur_test.rb` is run
   **Then** unit tests pass for: `operateur_pour_annee?`, `toutes_annees`, `activer!`, `desactiver!`

## Tasks / Subtasks

- [x] Task 1: Add `toutes_annees` method (AC: #1, #2, #3)
  - [x] 1.1: If `operateur_actif` is true, find the max contiguous start in `annees` and expand to current year
  - [x] 1.2: If `operateur_actif` is false, return `annees` as-is (sorted)
  - [x] 1.3: Handle edge case: gap in years (past segment stays, active segment expands)

- [x] Task 2: Add `operateur_pour_annee?(year)` method (AC: #4)
  - [x] 2.1: Return `toutes_annees.include?(year)`

- [x] Task 3: Add `activer!(annee)` method (AC: #5)
  - [x] 3.1: Add year to `annees` array if not present
  - [x] 3.2: Set `organisme.operateur_actif = true`
  - [x] 3.3: Save both operateur and organisme in transaction

- [x] Task 4: Add `desactiver!(annee_fin)` method (AC: #6)
  - [x] 4.1: Expand active range into individual years up to `annee_fin`
  - [x] 4.2: Set `organisme.operateur_actif = false`
  - [x] 4.3: Save both operateur and organisme in transaction

- [x] Task 5: Update `ransackable_attributes` (AC: #7)

- [x] Task 6: Write unit tests (AC: #8)
  - [x] 6.1: Test `toutes_annees` with active operator (single year → expanded)
  - [x] 6.2: Test `toutes_annees` with inactive operator (returns stored years)
  - [x] 6.3: Test `toutes_annees` with gaps in years
  - [x] 6.4: Test `operateur_pour_annee?` true and false cases
  - [x] 6.5: Test `activer!` sets correct state
  - [x] 6.6: Test `desactiver!` expands years and sets inactive

## Dev Notes

### File to Modify

**`app/models/operateur.rb`** — Currently 68 lines [Source: app/models/operateur.rb]

### Method Design — `toutes_annees`

The key logic: when `operateur_actif` is true, the `annees` array stores only the start year(s). The active contiguous range must be expanded dynamically to the current year.

```ruby
def toutes_annees
  return annees.sort unless organisme.operateur_actif

  # Find the start of the active contiguous block (highest year in annees
  # that begins a run going to "now")
  current_year = Date.today.year
  sorted = annees.sort
  # Past years (before last contiguous block) stay as-is
  # Active block: last element starts a range to current_year
  # Split: find where the active range starts
  active_start = sorted.last  # simplest: last stored year is start of active range
  past_years = sorted[0...-1]  # all except last
  active_range = (active_start..current_year).to_a
  (past_years + active_range).uniq.sort
end
```

**Edge case with gap:** `annees: [2018, 2019, 2024]`, `operateur_actif: true`
- `sorted.last` = 2024 → active range = [2024..2026]
- past_years = [2018, 2019]
- Result: [2018, 2019, 2024, 2025, 2026]

### Method Design — `activer!` and `desactiver!`

```ruby
def activer!(annee)
  transaction do
    self.annees = (annees + [annee]).uniq.sort
    save!
    organisme.update!(operateur_actif: true)
  end
end

def desactiver!(annee_fin)
  transaction do
    # Expand the active range to individual years
    expanded = toutes_annees.select { |y| y <= annee_fin }
    self.annees = expanded
    save!
    organisme.update!(operateur_actif: false)
  end
end
```

### Dependency on Story 1.1

This story requires Story 1.1 to be completed first — the `annees` column and `operateur_actif` column must exist.

### Test Fixtures

Story 1.1 updates fixtures. This story adds test cases in `test/models/operateur_test.rb` (currently empty — 7 lines).

You'll need to create fixture operateurs with different states:
- Active operator: `annees: [2024]` + organisme with `operateur_actif: true`
- Inactive operator: `annees: [2022, 2023]` + organisme with `operateur_actif: false`

### CRITICAL WARNINGS

1. **DO NOT modify import methods** — Story 4.3 handles that
2. **DO NOT modify controllers or views** — Those are Epic 2-5
3. **`toutes_annees` must handle empty `annees` gracefully** — return `[]`
4. **`organisme.operateur_actif` lives on the organismes table** — access via `organisme` association
5. **Use `transaction` blocks** for `activer!`/`desactiver!` to ensure atomicity

### References

- [Source: `app/models/operateur.rb` lines 1-68] — Current model
- [Source: `docs/plan-refactoring-operateur.md` lines 31-41] — Étape 2 spec
- [Source: `_bmad-output/planning-artifacts/epics.md` lines 125-155] — Story 1.2 AC
- [Source: `test/models/operateur_test.rb`] — Empty test file to populate

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6 (Amelia, Dev Agent)

### Debug Log References

- `desactiver!` v1 used `toutes_annees.select { |y| y <= annee_fin }` which capped at `Date.today.year` (2026) — failed test expecting 2027. Fixed by expanding directly from `active_start..annee_fin`.

### Completion Notes List

- `toutes_annees`: returns `annees.sort` when inactive; expands `sorted.last..Date.today.year` when active; handles empty arrays and gap years
- `operateur_pour_annee?`: delegates to `toutes_annees.include?`
- `activer!`: transactional, deduplicates with `uniq.sort`, sets `operateur_actif: true`
- `desactiver!`: expands `active_start..annee_fin` (future years included), sets `operateur_actif: false`
- `ransackable_attributes` already updated in story 1.1 ✅
- 13 unit tests, 21 assertions, 0 failures; full suite 24 runs, 0 failures ✅

### File List

- `app/models/operateur.rb` (modified — added 4 instance methods with input validation)
- `test/models/operateur_test.rb` (populated with 13 unit tests)

### Change Log

- 2026-02-24: Story 1.2 implemented — toutes_annees, operateur_pour_annee?, activer!, desactiver! with full unit test coverage
- 2026-02-24: Code review (Amelia/claude-opus-4-6) — Fixed: (H1) desactiver! crash on empty annees — added guard clause; (H2) activer!/desactiver! accept non-integer input — added ArgumentError validation; (M1) added 4 missing tests: desactiver! with gap years, empty annees, ArgumentError tests; (M3) fixed test setup destroying fixture operateurs to avoid has_one conflict; (L1) removed task-reference comments from production code.
