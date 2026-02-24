# Story 2.1: Operateur Form — Replace Radio Buttons with Toggle and Year Input

Status: ready-for-dev

## Story

As a **2B2O administrator**,
I want the operator form to show a simple toggle "Opérateur actif: Oui/Non" and a year input "Opérateur depuis (année)" instead of four radio button groups,
So that activating or deactivating an operator is simpler and more intuitive.

## Acceptance Criteria

1. **Given** the operator form (`app/views/operateurs/_form.html.erb`)
   **When** the form is displayed
   **Then** a DSFR-compliant radio group "Opérateur actif" (Oui/Non) replaces the four radio button groups (lines 29-108)
   **And** a numeric year input "Opérateur depuis (année)" is shown when "Oui" is selected
   **And** the category, programme, and mission fields remain and are enabled/disabled based on the toggle state

2. **Given** the JavaScript form controller (`form_controller.js`)
   **When** `ChangeOperateur()` is triggered
   **Then** it checks the new radio element (`#radio-operateur-actif-1`) instead of `[id^="radio-operateurn"]`
   **And** category, programme, mission, and linked programs are enabled/disabled based on toggle state

3. **Given** the operateurs controller
   **When** creating an operator with "Oui" and year "2026"
   **Then** `activer!(2026)` is called and the operator is saved with `annees: [2026]` and `operateur_actif: true`

4. **Given** the operateurs controller
   **When** updating an operator with "Non"
   **Then** `desactiver!(current_year)` is called
   **And** `operateur_params` permits `:operateur_actif`, `:annee_debut` instead of the four booleans

## Tasks / Subtasks

- [ ] Task 1: Update the form view (AC: #1)
  - [ ] 1.1: Replace lines 29-108 (4 radio groups) with single DSFR radio group for "Opérateur actif"
  - [ ] 1.2: Add numeric input field "Opérateur depuis (année)" with `display: none` when "Non"
  - [ ] 1.3: Pre-fill year from `@operateur.annees&.min` for existing operators
  - [ ] 1.4: Keep category, programme, mission, programmes annexes fields unchanged (lines 111-179)

- [ ] Task 2: Update JavaScript controller (AC: #2)
  - [ ] 2.1: Change `ChangeOperateur()` selector from `[id^="radio-operateurn"]` to `#radio-operateur-actif-1`
  - [ ] 2.2: Update `is_checked` logic to check single radio instead of `.some()`
  - [ ] 2.3: Add show/hide logic for `annee_debut` field based on toggle state

- [ ] Task 3: Update operateurs controller (AC: #3, #4)
  - [ ] 3.1: Update `create` method: replace boolean check (line 20) with `activer!` call
  - [ ] 3.2: Update `update` method: replace boolean check + destroy (line 38) with `activer!/desactiver!`
  - [ ] 3.3: Update `operateur_params`: replace 4 booleans with `:annee_debut`

## Dev Notes

### Files to Modify

1. **`app/views/operateurs/_form.html.erb`** — 198 lines
2. **`app/javascript/controllers/form_controller.js`** — ChangeOperateur() at lines 306-323
3. **`app/controllers/operateurs_controller.rb`** — 68 lines

### Current Form Structure (lines 29-108)

4 identical fieldsets, each with radio Oui/Non:
- "Opérateur PLF {year+1}" → `operateur_nf`
- "Opérateur PLF {year}" → `operateur_n`
- "Opérateur PLF {year-1}" → `operateur_n1`
- "Opérateur PLF {year-2}" → `operateur_n2`

Radio IDs: `radio-operateurnf-1`, `radio-operateurn-1`, `radio-operateurn1-1`, `radio-operateurn2-1`

**Replace with:**
```erb
<div class="fr-col-12 fr-col-lg-4">
  <fieldset class="fr-fieldset">
    <legend class="fr-fieldset__legend--regular fr-fieldset__legend">Opérateur actif*</legend>
    <div class="fr-fieldset__element fr-fieldset__element--inline">
      <div class="fr-radio-group">
        <input type="radio" name="operateur[operateur_actif]" value="true"
               id="radio-operateur-actif-1"
               <%= @operateur.organisme&.operateur_actif ? 'checked' : '' %>
               data-form-target="checkRequire"
               data-action="change->form#ChangeOperateur" />
        <label class="fr-label" for="radio-operateur-actif-1">Oui</label>
      </div>
    </div>
    <div class="fr-fieldset__element fr-fieldset__element--inline">
      <div class="fr-radio-group">
        <input type="radio" name="operateur[operateur_actif]" value="false"
               id="radio-operateur-actif-2"
               <%= !@operateur.organisme&.operateur_actif ? 'checked' : '' %>
               data-form-target="checkRequire"
               data-action="change->form#ChangeOperateur" />
        <label class="fr-label" for="radio-operateur-actif-2">Non</label>
      </div>
    </div>
  </fieldset>
</div>
<div class="fr-col-12 fr-col-lg-4" id="annee-debut-group">
  <div class="fr-input-group">
    <label class="fr-label" for="annee_debut">Opérateur depuis (année)*</label>
    <input type="number" class="fr-input" id="annee_debut"
           name="operateur[annee_debut]"
           value="<%= @operateur.annees&.min %>"
           min="2000" max="<%= Date.today.year + 2 %>"
           data-form-target="fieldRequire" />
  </div>
</div>
```

### Current Controller Logic

**create (line 20):**
```ruby
@operateur.save if @operateur.operateur_nf == true || @operateur.operateur_n == true || ...
```
**Replace with:**
```ruby
if params[:operateur][:operateur_actif] == 'true' && params[:operateur][:annee_debut].present?
  @operateur.save!
  @operateur.activer!(params[:operateur][:annee_debut].to_i)
end
```

**update (line 38):**
```ruby
@operateur.destroy if @operateur.operateur_nf == false && ...
```
**Replace with:**
```ruby
if params[:operateur][:operateur_actif] == 'false'
  @operateur.desactiver!(Date.today.year)
else
  @operateur.activer!(params[:operateur][:annee_debut].to_i) if params[:operateur][:annee_debut].present?
end
```

**operateur_params (lines 53-55):**
Replace `:operateur_nf, :operateur_n, :operateur_n1, :operateur_n2` with `:annee_debut`

### JavaScript — ChangeOperateur()

Current (lines 306-323):
```javascript
ChangeOperateur(){
    const operateurRadios = Array.from(this.element.querySelectorAll('[id^="radio-operateurn"]'));
    // ... uses operateurRadios.some(radio => radio.checked)
}
```

**Replace with:**
```javascript
ChangeOperateur(){
    const operateurActif = this.element.querySelector('#radio-operateur-actif-1');
    const is_checked = operateurActif && operateurActif.checked;
    const anneeDebutGroup = document.getElementById("annee-debut-group");

    if (anneeDebutGroup) {
        anneeDebutGroup.style.display = is_checked ? '' : 'none';
    }

    // Rest of existing logic stays the same (mission, programme, btn_rattachement)
    const mission = document.getElementById("mission");
    const programme = document.getElementById("programme");
    const btn_rattachement = document.getElementById("BtnRattachement");
    const presenceRadios = Array.from(this.element.querySelectorAll('[id^="radio-presence"]'));
    const checkedFields = Array.from(this.formTarget.querySelectorAll("input[type='checkbox']"));

    this.changeCheckDisable(!is_checked,...presenceRadios);
    this.ChangeCategorie();
    this.changeField(is_checked,programme);
    this.changeProgramme();
    this.changeField(is_checked,mission);
    this.changeDropdown(is_checked, btn_rattachement, checkedFields);
    this.checkBox();
}
```

### DSFR Compliance

- Radio groups: Use `fr-radio-group` class (already used in current form)
- Number input: Use `fr-input-group` + `fr-input` classes
- Follow existing DSFR patterns in the form

### CRITICAL WARNINGS

1. **Keep the `operateur_programmes` handling** in create/update (the `update_operateur_programmes` method) — unchanged
2. **Keep `presence_categorie`, `nom_categorie`, `programme_id`, `mission_id`** in `operateur_params` — only remove the 4 booleans
3. **The form uses `form_with(model: @operateur)`** — the new fields must work with Rails form helpers or manual input tags
4. **`annee_debut` is NOT a database column** — it's a virtual param processed by the controller to call `activer!`
5. **For new operators** (`new` action), the `@operateur.organisme` may be accessible via `@organisme` instead

### References

- [Source: `app/views/operateurs/_form.html.erb` lines 29-108] — 4 radio groups to replace
- [Source: `app/javascript/controllers/form_controller.js` lines 306-323] — ChangeOperateur method
- [Source: `app/controllers/operateurs_controller.rb` lines 16-56] — create/update/params
- [Source: `docs/plan-refactoring-operateur.md` lines 82-97] — Étapes 7-8

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
