# Story 4.3: Excel Import Adaptation — Backward-Compatible Year Array Construction

Status: done

## Story

As a **2B2O administrator**,
I want to continue importing operator data from the same Excel format while the system builds the `annees` array server-side,
So that the import process is unchanged from my perspective but the data is stored in the new format.

## Acceptance Criteria

1. **Given** the Operateur model `import` method (lines 10-47)
   **When** an Excel file with "operateur_n", "operateur_n1", "operateur_n2" columns (OUI/NON) is imported
   **Then** the OUI values are mapped to their corresponding years and stored in the `annees` array
   **And** if the operator already exists, imported years are merged with existing `annees`
   **And** `operateur_actif` on the organism is updated

2. **Given** the Organisme model `import` method (lines 98-121)
   **When** an Excel file with "Opérateur 2025", "Opérateur 2024" columns is imported
   **Then** the boolean-to-year mapping constructs the `annees` array correctly
   **And** `operateur_actif` is set based on the imported data

## Tasks / Subtasks

- [x] Task 1: Update `Operateur.import` method (AC: #1)
  - [x] 1.1: Replace line 21 check: map column values to years instead of checking booleans
  - [x] 1.2: Replace lines 23-27: build `annees` array from OUI columns
  - [x] 1.3: Merge with existing `annees` if operateur already exists
  - [x] 1.4: Set `operateur_actif` on organism
  - [x] 1.5: Handle "all NON" case (destroy operateur — line 43-44 existing behavior)

- [x] Task 2: Update `Organisme.import` method (AC: #2)
  - [x] 2.1: Replace lines 104-108 (boolean assignments) with year-based logic
  - [x] 2.2: Build annees array, merge with existing
  - [x] 2.3: Set operateur_actif on organism

## Dev Notes

### Files to Modify

1. **`app/models/operateur.rb`** — `self.import` method, lines 10-47
2. **`app/models/organisme.rb`** — `self.import` method, lines 98-121

### Operateur.import — Current Logic (lines 10-47)

```ruby
def self.import(file)
  data = Roo::Spreadsheet.open(file.path)
  headers = data.row(1)
  data.each_with_index do |row, idx|
    next if idx == 0
    row_data = Hash[[headers, row].transpose]
    siren = row_data['siren'].to_s
    next if siren.blank?
    organisme = Organisme.find_by(siren: siren)
    if organisme && [row_data['operateur_n'], row_data['operateur_n1'], row_data['operateur_n2']].any?('OUI')
      operateur = Operateur.where(organisme_id: organisme.id).first || Operateur.new(organisme_id: organisme.id)
      column_names_bis = %w[operateur_n operateur_n1 operateur_n2 presence_categorie nom_categorie]
      column_names_bis.each do |column_name|
        row_data[column_name] = convert_to_boolean(row_data[column_name])
      end
      operateur.attributes = row_data.slice(*column_names_bis)
      # ... programme/mission/save logic
    elsif organisme
      organisme.operateur&.destroy
    end
  end
end
```

### Operateur.import — New Logic

```ruby
def self.import(file)
  data = Roo::Spreadsheet.open(file.path)
  headers = data.row(1)
  current_year = Date.today.year

  # Map column names to years
  year_columns = {
    'operateur_n' => current_year,
    'operateur_n1' => current_year - 1,
    'operateur_n2' => current_year - 2
  }

  data.each_with_index do |row, idx|
    next if idx == 0
    row_data = Hash[[headers, row].transpose]
    siren = row_data['siren'].to_s
    next if siren.blank?

    organisme = Organisme.find_by(siren: siren)
    new_years = year_columns.select { |col, _| row_data[col]&.upcase == 'OUI' }.values

    if organisme && new_years.any?
      operateur = Operateur.where(organisme_id: organisme.id).first || Operateur.new(organisme_id: organisme.id)
      existing_years = operateur.annees || []
      merged_years = (existing_years + new_years).uniq.sort

      operateur.annees = merged_years
      operateur.presence_categorie = convert_to_boolean(row_data['presence_categorie'])
      operateur.nom_categorie = convert_to_boolean(row_data['nom_categorie'])

      # Programme/mission logic unchanged
      if row_data['programme']
        programme = Programme.find_by(numero: row_data['programme'].to_i)
        operateur.programme_id = programme&.id
        operateur.mission_id = Mission.find_by(programme_id: programme&.id)&.id if programme
      end

      if operateur.save
        is_active = new_years.any? { |y| y >= current_year }
        organisme.update(operateur_actif: is_active)
        # operateur_programmes handling unchanged
        operateur.operateur_programmes.destroy_all
        selected_programmes = (row_data['programmes_annexes'].to_s || '').split('-').map(&:to_i)
        selected_programmes.each do |programme_numero|
          p_id = Programme.find_by(numero: programme_numero)&.id
          operateur.operateur_programmes.create(programme_id: p_id) if p_id
        end
      end
    elsif organisme
      organisme.operateur&.destroy
      organisme.update(operateur_actif: false)
    end
  end
end
```

### Organisme.import — Lines 104-108

See Story 1.3 for the detailed spec. Replace:
```ruby
operateur_nf: convert_to_boolean(row_data['Opérateur 2025']),
operateur_n: convert_to_boolean(row_data['Opérateur 2024']),
operateur_n1: convert_to_boolean(row_data['Opérateur 2023']),
operateur_n2: convert_to_boolean(row_data['Opérateur 2022']),
```

With year-based annees construction (same pattern as Operateur.import).

### Two Different Import Formats

**CRITICAL:** The two import methods use DIFFERENT Excel formats:
- `Operateur.import`: lowercase columns without years — `operateur_n`, `operateur_n1`, `operateur_n2`
- `Organisme.import`: French columns with years — `Opérateur 2025`, `Opérateur 2024`, etc.

Each needs its own year-mapping logic.

### CRITICAL WARNINGS

1. **Two different import methods with different column names** — don't confuse them
2. **Merge years, never overwrite** — `(existing + new).uniq.sort`
3. **When destroying operateur**, also set `organisme.operateur_actif = false`
4. **The `operateur_nf` column is NOT in Operateur.import** (line 21 only checks n, n1, n2) — this is existing behavior, maintain it
5. **`convert_to_boolean`** helper returns `true`, `false`, or `nil` — check for exact `== true` or string `== 'OUI'`

### References

- [Source: `app/models/operateur.rb` lines 10-47] — Operateur.import
- [Source: `app/models/organisme.rb` lines 98-121] — Organisme.import
- [Source: `docs/plan-refactoring-operateur.md` lines 44-50] — Étape 3 spec

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

- Les deux méthodes `import` étaient déjà migrées (story 1.3). Cette story ajoute la couverture de tests manquante.
- `Minitest::Mock` non disponible sans require — approche `call_operateur_import_row` helper adoptée (même pattern qu'`organisme_test.rb`)

### Completion Notes List

- `Operateur.import` : déjà implémenté avec `year_map` et merge `(existing + new).uniq.sort`
- `Organisme.import` : déjà implémenté avec extraction dynamique `/Opérateur \d{4}/` et `convert_to_boolean`
- Aucun code de production modifié — les deux implémentations sont conformes aux ACs
- 4 tests ajoutés pour `Operateur.import` : OUI courant, OUI passé seulement, merge, destroy all NON
- `Organisme.import` déjà couvert par 4 tests existants dans `organisme_test.rb`
- 61 tests passent, 0 régression
- CR fix: H1 — `Operateur.import` destroy path missing `organisme.update(operateur_actif: false)` — added
- CR fix: added `refute organisme.operateur_actif` assertion to destroy test
- 61 tests, 199 assertions, 0 failures after CR

### File List

- test/models/operateur_test.rb
- app/models/operateur.rb (CR fix: added operateur_actif reset on destroy)

## Change Log

- 2026-02-25: Story 4.3 — implémentation déjà présente (story 1.3) ; ajout de 4 tests pour `Operateur.import`
- 2026-02-25: CR fix — H1: added `organisme.update(operateur_actif: false)` to destroy branch in `Operateur.import`
