# Story 2.2: Organism Show Page — Display Operator Status and Enable Editing

Status: ready-for-dev

## Story

As a **2B2O administrator or Contrôleur**,
I want the organism show page to display "Opérateur: Oui (depuis XXXX)" with year history, and allow editing the operator block directly,
So that I can see and manage operator status without navigating to a separate page.

## Acceptance Criteria

1. **Given** an organism that is an active operator since 2024
   **When** viewing the organism show page
   **Then** the operator section displays "Opérateur: Oui (depuis 2024)" instead of four separate year lines

2. **Given** an organism that is not an operator
   **When** viewing the organism show page
   **Then** the operator section displays "Opérateur: Non"

3. **Given** an inactive operator with history (e.g., annees: [2020, 2021, 2022])
   **When** viewing the organism show page
   **Then** it displays "Opérateur: Non" and shows the year list "Années: 2020, 2021, 2022"

4. **Given** a 2B2O user viewing the organism show page
   **When** they click the edit button on the operator block
   **Then** they navigate to the operator form (existing behavior — edit link unchanged)

5. **Given** the updated show page
   **Then** the category, mission, programme, and linked programs fields remain displayed as before

## Tasks / Subtasks

- [ ] Task 1: Update the operator display section (AC: #1, #2, #3, #5)
  - [ ] 1.1: Replace lines 295-322 (4 year lines) with new lifecycle display
  - [ ] 1.2: Show "Opérateur: Oui (depuis XXXX)" for active operators
  - [ ] 1.3: Show "Opérateur: Non" for non-operators
  - [ ] 1.4: Show year history for inactive operators with history
  - [ ] 1.5: Keep category, mission, programme, programmes annexes display (lines 323-341)

## Dev Notes

### File to Modify

**`app/views/organismes/show.html.erb`** — operator section at lines 280-346

### Current Display (lines 295-322)

```erb
<h3 class="fr-card__title">
  Opérateur année
  <% if Date.today < Date.new(Date.today.year, 9, 30) %>
    <%= Date.today.year %> : <%= format_boolean(@operateur.operateur_n) %>
  <% else %>
    <%= Date.today.year + 1 %> : <%= format_boolean(@operateur.operateur_nf) %>
  <% end %>
</h3>
<!-- Then separate <p> for each year: operateur_n, operateur_n1, operateur_n2 -->
```

### New Display

```erb
<h3 class="fr-card__title">
  <% if @operateur && @organisme.operateur_actif %>
    Opérateur : Oui (depuis <%= @operateur.annees&.min %>)
  <% else %>
    Opérateur : Non
  <% end %>
</h3>
<% if @operateur && !@organisme.operateur_actif && @operateur.annees.present? %>
  <p class="fr-card__desc">Années opérateur : <b><%= @operateur.annees.sort.join(', ') %></b></p>
<% elsif @operateur && @organisme.operateur_actif %>
  <p class="fr-card__desc">Années opérateur : <b><%= @operateur.toutes_annees.join(', ') %></b></p>
<% end %>
```

### Edit Button Logic

Lines 282-289 — **unchanged**. The edit/new button logic is controlled by `@statut_user == "2B2O"` and whether `@operateur` exists. This works as-is.

### Instance Variables in Show Action

`@operateur` is loaded at line 75 of `organismes_controller.rb`:
```ruby
@operateur = Operateur.includes(:mission, :programme, :operateur_programmes).find_by(organisme_id: @organisme.id)
```

`@organisme` is loaded via `set_organisme`. The new `operateur_actif` field is on `@organisme` directly — no additional query needed.

### CRITICAL WARNINGS

1. **Keep the edit button logic (lines 282-289) exactly as-is** — just modify the display content
2. **Keep category, mission, programme, programmes annexes (lines 323-341)** — these are unchanged
3. **`@operateur` can be nil** — always guard with `if @operateur`
4. **`@organisme.operateur_actif`** is the denormalized flag — use it for the Oui/Non display
5. **`@operateur.toutes_annees`** uses the new model method from Story 1.2

### References

- [Source: `app/views/organismes/show.html.erb` lines 280-346] — Operator section
- [Source: `app/controllers/organismes_controller.rb` line 75] — @operateur loading
- [Source: `docs/plan-refactoring-operateur.md` lines 101-107] — Étape 9 show spec

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
