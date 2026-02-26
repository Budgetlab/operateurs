# Story 5.2: ActiveAdmin & Final Cleanup

Status: done

## Story

As an **admin user**,
I want ActiveAdmin to work with the new data model, and all legacy boolean references to be removed from the codebase,
So that the codebase is clean with no references to the old four-boolean model.

## Acceptance Criteria

1. **Given** the ActiveAdmin operateurs resource (`app/admin/operateurs.rb`)
   **When** the admin panel is loaded
   **Then** `permit_params` includes `annees: []` instead of the four boolean columns

2. **Given** the complete codebase
   **When** searching for references to `operateur_nf`, `operateur_n`, `operateur_n1`, `operateur_n2`
   **Then** zero references are found (only migration files and schema history may contain them)

3. **Given** the test suite
   **When** `rails test` is run
   **Then** all tests pass without regression

## Tasks / Subtasks

- [x] Task 1: Update ActiveAdmin permit_params (AC: #1)
  - [x] 1.1: Replace line 8 in `app/admin/operateurs.rb`

- [x] Task 2: Codebase sweep for legacy references (AC: #2)
  - [x] 2.1: Search entire codebase for `operateur_nf`, `operateur_n[^_]`, `operateur_n1`, `operateur_n2`
  - [x] 2.2: Remove or replace any remaining references (excluding migration files and schema.rb)

- [x] Task 3: Run full test suite (AC: #3)
  - [x] 3.1: Run `rails test` and verify all tests pass
  - [x] 3.2: Fix any test failures related to removed columns

## Dev Notes

### Files to Modify

1. **`app/admin/operateurs.rb`** — 18 lines

### ActiveAdmin — Current (line 8)

```ruby
permit_params :organisme_id, :operateur_n, :operateur_n1, :operateur_n2, :presence_categorie, :nom_categorie, :mission_id, :programme_id, :operateur_nf
```

**Replace with:**
```ruby
permit_params :organisme_id, :presence_categorie, :nom_categorie, :mission_id, :programme_id, annees: []
```

### Codebase Sweep Checklist

After all previous stories are complete, search for any remaining references:

```bash
grep -r "operateur_nf\|operateur_n[^_a-z]\|operateur_n1\|operateur_n2" --include="*.rb" --include="*.erb" --include="*.js" --include="*.yml" app/ test/ config/
```

Expected locations that may still have references (acceptable):
- `db/migrate/` — migration files (keep as-is)
- `db/schema.rb` — should NOT have them after migration runs

Locations that must NOT have references:
- `app/models/`
- `app/controllers/`
- `app/views/`
- `app/javascript/`
- `app/admin/`
- `test/fixtures/`
- `test/models/`

### Test Fixtures

Story 1.1 updated `test/fixtures/operateurs.yml`. Verify they work:
```yaml
one:
  organisme: one
  annees:
    - 2025
    - 2026
  presence_categorie: false
  nom_categorie: MyString
  mission: one
  programme: one
```

Also verify `test/fixtures/organismes.yml` includes `operateur_actif` if the fixture uses operator-related test scenarios.

### CRITICAL WARNINGS

1. **Run this story LAST** — it's the final cleanup, all other stories must be done
2. **The grep pattern for `operateur_n` needs care** — `operateur_n` matches `operateur_nf`, `operateur_n1`, etc. Use `operateur_n[^_a-z]` to match only the bare `operateur_n`
3. **Don't modify migration files** — they are historical records
4. **ActiveAdmin may need a restart** to pick up model changes

### References

- [Source: `app/admin/operateurs.rb` line 8] — Current permit_params
- [Source: `docs/plan-refactoring-operateur.md` lines 126-141] — Étapes 11-12

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

None.

### Completion Notes List

- Task 1: `app/admin/operateurs.rb` — `permit_params` remplacé : suppression des 4 booleans, ajout de `annees: []`.
- Task 2: Sweep complet — seules références restantes à `operateur_n/n1/n2` sont dans `Operateur.import` (clés de colonnes Excel pour import backward-compatible, story 4.3) et les tests associés. `db/schema.rb` ne contient aucune référence aux colonnes supprimées. Aucune suppression nécessaire — ces références sont fonctionnelles et intentionnelles.
- Task 3: 64 tests, 0 failures, 0 errors.
- CR: CLEAN — independent codebase sweep confirmed zero legacy references outside intentional Excel import keys. All ACs verified.

### File List

- app/admin/operateurs.rb

## Change Log

- 2026-02-25: Story 5.2 implemented — ActiveAdmin permit_params updated, codebase sweep clean
- 2026-02-25: CR passed clean — independent sweep confirmed, all 64 tests pass
