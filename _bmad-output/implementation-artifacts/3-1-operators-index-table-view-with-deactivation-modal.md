# Story 3.1: Operators Index — Table View with Deactivation Modal

Status: ready-for-dev

## Story

As a **2B2O administrator**,
I want the operators index page to display a table of all operators with their status, and a "Rendre inactif" button that opens a modal asking for the end year,
So that I can quickly see all operators and deactivate any of them without navigating to individual pages.

## Acceptance Criteria

1. **Given** the operators index page (`/opera/operateurs`)
   **When** a 2B2O user navigates to it
   **Then** a DSFR-compliant table displays: Organisme, Programme, Mission, Catégorie, Statut (Actif/Inactif), Années
   **And** active operators show a "Rendre inactif" button
   **And** inactive operators show their year range without the button

2. **Given** an active operator in the table
   **When** the user clicks "Rendre inactif"
   **Then** a DSFR modal opens with: year input "Inactif depuis (année)", "Confirmer" button, "Annuler" button

3. **Given** the deactivation modal is open
   **When** the user enters year "2027" and clicks "Confirmer"
   **Then** `desactiver!(2027)` is called on the operator
   **And** the table updates (page refresh or Turbo Stream)
   **And** a success flash message is displayed

4. **Given** the deactivation modal is open
   **When** the user clicks "Annuler"
   **Then** the modal closes without changes

## Tasks / Subtasks

- [ ] Task 1: Update operators index view (AC: #1)
  - [ ] 1.1: Replace current index content with DSFR table
  - [ ] 1.2: Add columns: Organisme (link to show), Programme, Mission, Catégorie, Statut, Années
  - [ ] 1.3: Add "Rendre inactif" button for active operators
  - [ ] 1.4: Display year range for inactive operators

- [ ] Task 2: Add DSFR deactivation modal (AC: #2, #4)
  - [ ] 2.1: Create modal markup following DSFR `fr-modal` pattern
  - [ ] 2.2: Add year input field and confirm/cancel buttons
  - [ ] 2.3: Wire button to open modal (DSFR `aria-controls`)

- [ ] Task 3: Add deactivation endpoint (AC: #3)
  - [ ] 3.1: Add `deactivate` action to `OperateursController`
  - [ ] 3.2: Call `@operateur.desactiver!(year)` and redirect with flash
  - [ ] 3.3: Add route for the deactivation action

## Dev Notes

### Files to Modify/Create

1. **`app/views/operateurs/index.html.erb`** — current index view (needs full rewrite of content)
2. **`app/controllers/operateurs_controller.rb`** — add `deactivate` action
3. **`config/routes.rb`** — add deactivation route

### Current Index View

The current `index` action (line 7) simply loads `@operateurs = Operateur.all`. The view likely shows a basic list. It needs to be enhanced with a table.

### DSFR Table Pattern

```erb
<div class="fr-table">
  <table>
    <thead>
      <tr>
        <th>Organisme</th>
        <th>Programme</th>
        <th>Mission</th>
        <th>Catégorie</th>
        <th>Statut</th>
        <th>Années</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <% @operateurs.each do |operateur| %>
        <tr>
          <td><%= link_to operateur.organisme.nom, organisme_path(operateur.organisme) %></td>
          <td><%= operateur.programme&.numero %></td>
          <td><%= operateur.mission&.nom %></td>
          <td><%= operateur.nom_categorie %></td>
          <td><%= operateur.organisme.operateur_actif ? 'Actif' : 'Inactif' %></td>
          <td><%= operateur.toutes_annees.join(', ') %></td>
          <td>
            <% if operateur.organisme.operateur_actif %>
              <button class="fr-btn fr-btn--secondary fr-btn--sm"
                      aria-controls="modal-deactivate-<%= operateur.id %>"
                      data-fr-opened="false">
                Rendre inactif
              </button>
            <% end %>
          </td>
        </tr>
      <% end %>
    </tbody>
  </table>
</div>
```

### DSFR Modal Pattern

```erb
<dialog id="modal-deactivate-<%= operateur.id %>" class="fr-modal" aria-labelledby="modal-title-<%= operateur.id %>">
  <div class="fr-container fr-container--fluid fr-container-md">
    <div class="fr-grid-row fr-grid-row--center">
      <div class="fr-col-12 fr-col-md-8">
        <div class="fr-modal__body">
          <div class="fr-modal__header">
            <button class="fr-btn--close fr-btn" aria-controls="modal-deactivate-<%= operateur.id %>">Fermer</button>
          </div>
          <div class="fr-modal__content">
            <h1 id="modal-title-<%= operateur.id %>" class="fr-modal__title">
              Rendre inactif — <%= operateur.organisme.nom %>
            </h1>
            <%= form_with url: deactivate_operateur_path(operateur), method: :patch, local: true do |f| %>
              <div class="fr-input-group">
                <label class="fr-label" for="annee_fin_<%= operateur.id %>">Inactif depuis (année)</label>
                <input type="number" class="fr-input" id="annee_fin_<%= operateur.id %>"
                       name="annee_fin" value="<%= Date.today.year %>"
                       min="2000" max="<%= Date.today.year + 2 %>" />
              </div>
              <div class="fr-modal__footer">
                <ul class="fr-btns-group fr-btns-group--right fr-btns-group--inline">
                  <li><button type="button" class="fr-btn fr-btn--secondary" aria-controls="modal-deactivate-<%= operateur.id %>">Annuler</button></li>
                  <li><%= f.submit 'Confirmer', class: 'fr-btn' %></li>
                </ul>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
  </div>
</dialog>
```

### Controller Deactivation Action

```ruby
def deactivate
  @operateur = Operateur.find(params[:id])
  @operateur.desactiver!(params[:annee_fin].to_i)
  redirect_to operateurs_path, flash: { notice: "#{@operateur.organisme.nom} est maintenant inactif." }
end
```

### Route Addition

```ruby
resources :operateurs do
  member do
    patch :deactivate
  end
end
```

Check existing routes structure first — the current routes may be different.

### Index Action — Eager Loading

Update the `index` action to eager-load associations:
```ruby
def index
  @operateurs = Operateur.includes(:organisme, :mission, :programme).all
end
```

### CRITICAL WARNINGS

1. **Check existing routes** before adding — `config/routes.rb` may use different nesting
2. **The DSFR modal uses `<dialog>` element** and `aria-controls` — DSFR JS handles open/close automatically
3. **`before_action :authenticate_admin!`** already protects all operateur actions (line 5)
4. **Eager load associations** in index to avoid N+1 queries
5. **The `desactiver!` method** is from Story 1.2 — this story depends on Epic 1 being done

### References

- [Source: `app/controllers/operateurs_controller.rb` lines 6-8] — Current index action
- [Source: `_bmad-output/planning-artifacts/epics.md` lines 237-266] — Story 3.1 AC
- [Source: `docs/plan-refactoring-operateur.md`] — No specific section for index (new feature)
- [Source: DSFR docs] — `fr-modal`, `fr-table` components

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
