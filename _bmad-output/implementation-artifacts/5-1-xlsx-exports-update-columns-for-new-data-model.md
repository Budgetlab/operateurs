# Story 5.1: XLSX Exports — Update Columns for New Data Model

Status: ready-for-dev

## Story

As a **user (any role)**,
I want the XLSX exports to show "Opérateur actif" and "Années opérateur" columns instead of four separate year columns,
So that exports contain richer historical data in a cleaner format.

## Acceptance Criteria

1. **Given** the organisms index XLSX export (`index.xlsx.axlsx`)
   **When** an export is generated
   **Then** the four columns "Opérateur YYYY" are replaced by two columns: "Opérateur actif" (Oui/Non) and "Années opérateur"
   **And** active operators show all dynamically expanded years
   **And** column count changes from 57 to 55, style ranges adjusted

2. **Given** the organism show XLSX export (`show.xlsx.axlsx`)
   **When** an export is generated
   **Then** the same column changes are applied
   **And** column count changes from 59 to 57, style ranges adjusted

## Tasks / Subtasks

- [ ] Task 1: Update index.xlsx.axlsx (AC: #1)
  - [ ] 1.1: Replace 4 operateur year headers with 2: "Opérateur actif", "Années opérateur"
  - [ ] 1.2: Update `array_operateur` construction (line 31)
  - [ ] 1.3: Update `sheet_col` from 57 to 55 (line 8)
  - [ ] 1.4: Update auto_filter range (line 11)
  - [ ] 1.5: Update style ranges (lines 46-48) — shift all column letters after operateur section by -2

- [ ] Task 2: Update show.xlsx.axlsx (AC: #2)
  - [ ] 2.1: Same header changes as index
  - [ ] 2.2: Update `array_operateur` construction (line 28)
  - [ ] 2.3: Update `sheet_col` from 59 to 57 (line 9)
  - [ ] 2.4: Update style ranges (lines 41-42) — shift by -2

## Dev Notes

### Files to Modify

1. **`app/views/organismes/index.xlsx.axlsx`** — 53 lines
2. **`app/views/organismes/show.xlsx.axlsx`** — 43 lines

### index.xlsx.axlsx — Current Headers (line 7)

The headers array includes 4 operateur columns at positions 14-17 (0-indexed):
```
... "Commentaire", "Opérateur 2027", "Opérateur 2026", "Opérateur 2025", "Opérateur 2024", "Appartenance catégorie opérateurs" ...
```

**Replace with 2 columns:**
```
... "Commentaire", "Opérateur actif", "Années opérateur", "Appartenance catégorie opérateurs" ...
```

### Current `array_operateur` (line 31)

```ruby
array_operateur = operateur ? [
  format_boolean(operateur.operateur_nf),
  format_boolean(operateur.operateur_n),
  format_boolean(operateur.operateur_n1),
  format_boolean(operateur.operateur_n2),
  format_boolean(operateur.presence_categorie),
  nom_categorie,
  format_boolean(operateur.mission.nom),
  format_boolean(operateur.programme.numero)
] : ["Non","Non","Non","Non","Non","N/A","N/A","N/A"]
```

**Replace with:**
```ruby
array_operateur = operateur ? [
  organisme.operateur_actif ? "Oui" : "Non",
  operateur.toutes_annees.join(', '),
  format_boolean(operateur.presence_categorie),
  nom_categorie,
  format_boolean(operateur.mission.nom),
  format_boolean(operateur.programme.numero)
] : ["Non", "", "Non", "N/A", "N/A", "N/A"]
```

### Column Count Changes

**index.xlsx.axlsx:**
- `sheet_col = Array.new(57, 13)` → `Array.new(55, 13)` (line 8)
- Auto filter: `"A1:BE1"` → `"A1:BC1"` (line 11, BE-2=BC)

**show.xlsx.axlsx:**
- `sheet_col = Array.new(59, 13)` → `Array.new(57, 13)` (line 9)

### Style Range Shifts

The styles use column letter ranges for alternating background colors. Removing 2 columns shifts everything after column O (operateur section) by -2 letters.

**index.xlsx.axlsx (lines 46-48):**
```ruby
# Current:
sheet.add_style ["N2:N#{lt}","W2:W#{lt}", "AB2:AB#{lt}", "AL2:AL#{lt}", "AQ2:AQ#{lt}", "AW2:AW#{lt}"], border: ...
sheet.add_style ["A1:N#{lt}", "X1:AB#{lt}", "AM1:AQ#{lt}", "AX1:BE#{lt}"], bg_color: "E5E5E5"
sheet.add_style ["O1:W#{lt}","AC1:AL#{lt}", "AR1:AW#{lt}"], bg_color: "E8EDFF"

# New (shift by -2 after column N):
sheet.add_style ["N2:N#{lt}","U2:U#{lt}", "Z2:Z#{lt}", "AJ2:AJ#{lt}", "AO2:AO#{lt}", "AU2:AU#{lt}"], border: ...
sheet.add_style ["A1:N#{lt}", "V1:Z#{lt}", "AK1:AO#{lt}", "AV1:BC#{lt}"], bg_color: "E5E5E5"
sheet.add_style ["O1:U#{lt}","AA1:AJ#{lt}", "AP1:AU#{lt}"], bg_color: "E8EDFF"
```

**IMPORTANT:** Manually verify the column letter math. The operateur section starts at column O (index 14). With 2 fewer columns, all letters from O onwards shift. But the operateur block itself goes from 4→2, so:
- Columns A-N (0-13): unchanged
- Column O: "Opérateur actif" (was "Opérateur 2027")
- Column P: "Années opérateur" (was "Opérateur 2026")
- Column Q: "Appartenance catégorie" (was at S, column 18 → now column 16)
- Everything after shifts by -2

**show.xlsx.axlsx (lines 41-42):**
Same pattern but different ranges. Verify against actual file content.

### CRITICAL WARNINGS

1. **Count column letters carefully** — off-by-one errors in Excel column letters break styling
2. **The `add_row` call (line 40 index, line 37 show)** uses `array_operateur[0..N]` indexed values — make sure indices match the new 6-element array (was 8)
3. **`toutes_annees` returns an array** — use `.join(', ')` for the export string
4. **Default for no-operator** changes from 4 "Non" to 1 "Non" + 1 empty string
5. **Test exports manually** — download and verify column alignment

### References

- [Source: `app/views/organismes/index.xlsx.axlsx`] — Full file (53 lines)
- [Source: `app/views/organismes/show.xlsx.axlsx`] — Full file (43 lines)
- [Source: `docs/plan-refactoring-operateur.md` lines 114-122] — Étape 10 spec

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
