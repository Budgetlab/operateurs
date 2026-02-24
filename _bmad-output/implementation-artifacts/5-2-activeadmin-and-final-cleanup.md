# Story 5.2: ActiveAdmin & Final Cleanup

Status: ready-for-dev

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

- [ ] Task 1: Update ActiveAdmin permit_params (AC: #1)
  - [ ] 1.1: Replace line 8 in `app/admin/operateurs.rb`

- [ ] Task 2: Codebase sweep for legacy references (AC: #2)
  - [ ] 2.1: Search entire codebase for `operateur_nf`, `operateur_n[^_]`, `operateur_n1`, `operateur_n2`
  - [ ] 2.2: Remove or replace any remaining references (excluding migration files and schema.rb)

- [ ] Task 3: Run full test suite (AC: #3)
  - [ ] 3.1: Run `rails test` and verify all tests pass
  - [ ] 3.2: Fix any test failures related to removed columns

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

### Debug Log References

### Completion Notes List

### File List
