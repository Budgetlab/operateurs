# Story 4.1: Organism Index Filtering — Simplify to operateur_actif

Status: done

## Story

As a **user (any role)**,
I want the organism index page filter to use a simple "Opérateur: Oui/Non" filter instead of the complex multi-param logic,
So that filtering organisms by operator status is intuitive and reliable.

## Acceptance Criteria

1. **Given** the organismes controller index method (lines 28-46)
   **When** the complex `operateur_operateur_n_null` / `operateur_operateur_n_in` filter logic is replaced
   **Then** a simple `operateur_actif_in` filter on the `organismes` table is used
   **And** the 19 lines of special-case logic are removed

2. **Given** the organisms index view (lines 62-76)
   **When** the filter section is rendered
   **Then** a simple DSFR tag group "Opérateur: Oui / Non" uses `operateur_actif_in` params

3. **Given** a user selects "Opérateur: Oui"
   **When** the filter is applied
   **Then** only organisms with `operateur_actif == true` are shown
   **And** the filter works consistently across all roles

## Tasks / Subtasks

- [x] Task 1: Simplify controller index method (AC: #1)
  - [x] 1.1: Remove lines 28-46 (entire complex operateur filter block)
  - [x] 1.2: The `operateur_actif_in` filter works natively via Ransack on the organismes table — no custom logic needed

- [x] Task 2: Update `q_params` (AC: #1)
  - [x] 2.1: Remove `:operateur_operateur_n_null` and `:operateur_operateur_n_in` from permitted params (line 373)
  - [x] 2.2: Add `:operateur_actif_in => []` to permitted params

- [x] Task 3: Update index view filter (AC: #2)
  - [x] 3.1: Replace lines 62-76 (complex tag group) with simple `operateur_actif_in` tag group

## Dev Notes

### Files to Modify

1. **`app/controllers/organismes_controller.rb`** — lines 28-46 (delete), line 373 (update params)
2. **`app/views/organismes/index.html.erb`** — lines 62-76 (simplify filter)

### Current Controller Logic (lines 28-46) — TO DELETE

```ruby
if q_params_send
  if q_params_send[:operateur_operateur_n_null] == 'true' && q_params[:operateur_operateur_n_in]&.include?('true')
    value_reset_all = true
    q_params_send.delete(:operateur_operateur_n_null)
    q_params_send.delete(:operateur_operateur_n_in)
  elsif q_params_send[:operateur_operateur_n_null] == 'true'
    value_reset_operateur_n = true
    q_params_send.delete(:operateur_operateur_n_null)
    extended_family_organisms = extended_family_organisms.where(operateurs: { operateur_n: [nil, false] })
  end
end
# ... then later:
if value_reset_all
  q_params_send[:operateur_operateur_n_null] = 'true'
  q_params_send[:operateur_operateur_n_in] = ["true"]
elsif value_reset_operateur_n
  q_params_send[:operateur_operateur_n_null] = 'true'
end
```

**All of this is replaced by nothing.** The `operateur_actif_in` filter works directly via Ransack since `operateur_actif` is on the `organismes` table.

### New q_params (line 371-388)

Remove from the permit list:
- `:operateur_operateur_n_null`
- `:operateur_operateur_n_in => []`

Add:
- `:operateur_actif_in => []`

### Current View Filter (lines 62-76)

```erb
<div class="fr-label fr-text--bold">Opérateur</div>
<ul class="fr-tags-group fr-my-1w">
  <li>
    <button class="fr-tag" ... aria-pressed="<%= ... operateur_operateur_n_in ... %>">
      <label><%= check_box_tag "q[operateur_operateur_n_in][]", true, ... %> Oui</label>
    </button>
  </li>
  <li>
    <button class="fr-tag" ... aria-pressed="<%= ... operateur_operateur_n_null ... %>">
      <label><%= check_box_tag "q[operateur_operateur_n_null]", true, ... %> Non</label>
    </button>
  </li>
</ul>
```

**Replace with:**
```erb
<div class="fr-label fr-text--bold">Opérateur</div>
<ul class="fr-tags-group fr-my-1w">
  <li>
    <button class="fr-tag" data-action="click->request#checkTag"
            aria-pressed="<%= params[:q] && params[:q][:operateur_actif_in]&.include?('true') ? 'true' : 'false' %>">
      <label><%= check_box_tag "q[operateur_actif_in][]", true,
             params[:q] && params[:q][:operateur_actif_in]&.include?('true'),
             { class: 'fr-hidden' } %> Oui</label>
    </button>
  </li>
  <li>
    <button class="fr-tag" data-action="click->request#checkTag"
            aria-pressed="<%= params[:q] && params[:q][:operateur_actif_in]&.include?('false') ? 'true' : 'false' %>">
      <label><%= check_box_tag "q[operateur_actif_in][]", false,
             params[:q] && params[:q][:operateur_actif_in]&.include?('false'),
             { class: 'fr-hidden' } %> Non</label>
    </button>
  </li>
</ul>
```

### Why This Works

`operateur_actif` is a boolean directly on the `organismes` table. Ransack's `_in` predicate handles `['true']` and `['false']` values natively. No need for the complex null-checking workaround that was required when filtering through the `operateurs` association.

### CRITICAL WARNINGS

1. **Delete the ENTIRE block lines 28-46** — don't leave partial logic
2. **Also delete the `value_reset_all`/`value_reset_operateur_n` variables** and their usage (lines 41-46)
3. **The filter now uses `operateur_actif_in`** — both "Oui" and "Non" can be selected simultaneously (shows all, same as no filter)
4. **Keep all other filters unchanged** — catégorie, mission, programme filters still use the operateur association and work fine
5. **Ransack `operateur_actif` is on organismes** — NOT through the operateur association, so it's `operateur_actif_in` not `operateur_operateur_actif_in`

### References

- [Source: `app/controllers/organismes_controller.rb` lines 28-46] — Complex filter logic to remove
- [Source: `app/controllers/organismes_controller.rb` lines 371-388] — q_params to update
- [Source: `app/views/organismes/index.html.erb` lines 62-76] — Filter tags to simplify
- [Source: `docs/plan-refactoring-operateur.md` lines 64-69] — Étape 5 spec

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

None — clean implementation, no blockers.

### Completion Notes List

- Removed 19-line complex operateur filter block from `OrganismesController#index` (lines 28-46)
- Removed `value_reset_all`/`value_reset_operateur_n` variables and their post-ransack reset logic (lines 41-46)
- `@q` now ransacks `params[:q]` directly (no intermediate manipulation)
- Removed legacy params `:operateur_operateur_n_null` and `:operateur_operateur_n_in => []` from `q_params` permit list
- Added `:operateur_actif_in => []` to `q_params` permit list
- Updated index view filter (lines 62-76) to use `operateur_actif_in` with Oui/Non tags
- Added 3 controller tests: filter true, filter false, legacy param ignored
- All 53 tests pass, 0 regressions
- CR: CLEAN — no findings, no fixes needed. All ACs verified, no residual legacy code.

### File List

- app/controllers/organismes_controller.rb
- app/views/organismes/index.html.erb
- test/controllers/organismes_controller_test.rb

## Change Log

- 2026-02-25: Story 4.1 implemented — simplified operateur filter from complex null-check logic to direct `operateur_actif_in` Ransack predicate
- 2026-02-25: CR passed clean — no issues found, all ACs verified
