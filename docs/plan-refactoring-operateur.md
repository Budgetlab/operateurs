# Refactoring Opérateur : des booléens annuels vers un array d'années

## Contexte

Aujourd'hui la table `operateurs` utilise 4 colonnes booléennes (`operateur_nf`, `operateur_n`, `operateur_n1`, `operateur_n2`) pour indiquer si un organisme est opérateur sur 4 années glissantes. Cela oblige à réimporter toutes les données chaque année et l'historique est limité à 4 ans.

**Objectif :** Remplacer ces 4 booléens par une colonne `annees integer[]` + un flag `operateur_actif` sur `organismes`. Quand l'opérateur est actif, on stocke uniquement l'année de début (pas de mise à jour annuelle). Quand il passe inactif, on développe les années dans le tableau.

**Exemple de cycle de vie :**
1. Actif depuis 2018 : `annees: [2018]`, `operateur_actif: true` → interprété comme opérateur 2018 à aujourd'hui
2. Passe inactif en 2022 : `annees: [2018, 2019, 2020, 2021]`, `operateur_actif: false`
3. Réactivé en 2024 : `annees: [2018, 2019, 2020, 2021, 2024]`, `operateur_actif: true` → 2018-2021 + 2024 à aujourd'hui

---

## Étape 1 — Migration de base de données

**Fichier :** `db/migrate/XXXXXX_refactor_operateur_annees.rb`

Actions :
1. Ajouter `annees integer[], default: []` sur `operateurs`
2. Ajouter `operateur_actif boolean, default: false` sur `organismes`
3. Migrer les données existantes (hardcodé : nf=2027, n=2026, n1=2025, n2=2024)
   - Si `operateur_n` ou `operateur_nf` est true → opérateur actif, on stocke la première année de la plage contiguë courante
   - Sinon → inactif, on stocke toutes les années où les booléens sont true
4. Supprimer les colonnes `operateur_nf`, `operateur_n`, `operateur_n1`, `operateur_n2`
5. Ajouter un index GIN sur `annees`

---

## Étape 2 — Modèle Operateur

**Fichier :** `app/models/operateur.rb`

- Ajouter les méthodes helper :
  - `toutes_annees` — retourne toutes les années (étend la plage active dynamiquement)
  - `operateur_pour_annee?(year)` — vérifie si opérateur pour une année donnée
  - `activer!(annee)` — ajoute l'année, met `operateur_actif = true`
  - `desactiver!(annee_fin)` — développe les années, met `operateur_actif = false`
- Mettre à jour `ransackable_attributes` (retirer les 4 booléens, ajouter `annees`)
- Mettre à jour la méthode `import` pour construire le tableau `annees` à partir des colonnes Excel

---

## Étape 3 — Modèle Organisme

**Fichier :** `app/models/organisme.rb`

- Ajouter `"operateur_actif"` dans `ransackable_attributes`
- Mettre à jour `Organisme.import` : remplacer l'affectation des 4 booléens par la construction du tableau `annees` et le flag `operateur_actif`

---

## Étape 4 — Contrôleur Operateurs

**Fichier :** `app/controllers/operateurs_controller.rb`

- **create :** remplacer le test `operateur_nf == true || operateur_n == true || ...` par une logique basée sur `annees` et `operateur_actif`
- **update :** remplacer le test `destroy if all false` par la gestion `activer!/desactiver!`
- **operateur_params :** remplacer les 4 booléens par `:operateur_actif`, `:annee_debut`, `annees: []`

---

## Étape 5 — Contrôleur Organismes

**Fichier :** `app/controllers/organismes_controller.rb`

- **Index (lignes 28-46) :** Supprimer toute la logique complexe `operateur_operateur_n_null` / `operateur_operateur_n_in`. Le filtre `operateur_actif_in` sur la table organismes suffit.
- **q_params :** Remplacer `:operateur_operateur_n_in`, `:operateur_operateur_n_null` par `:operateur_actif_in => []`

---

## Étape 6 — Contrôleur Chiffres

**Fichier :** `app/controllers/chiffres_controller.rb`

- **select_exercice :** Remplacer le `case/when` sur les 4 booléens par `operateur&.operateur_pour_annee?(date.to_i)`

---

## Étape 7 — Formulaire opérateur

**Fichier :** `app/views/operateurs/_form.html.erb`

- Remplacer les 4 groupes de radio buttons (lignes 29-108) par :
  - Un toggle Oui/Non pour "Opérateur actif"
  - Un champ numérique pour "Opérateur depuis (année)"
  - Un affichage de l'historique si existant

---

## Étape 8 — JavaScript

**Fichier :** `app/javascript/controllers/form_controller.js`

- **ChangeOperateur() (ligne 306-323) :** Remplacer le sélecteur `[id^="radio-operateurn"]` par `#radio-operateur-actif-1`
- Ajouter la gestion du champ `annee_debut` dans les champs conditionnels

---

## Étape 9 — Vues organismes

### show.html.erb (lignes 280-342)
- Remplacer l'affichage des 4 années par :
  - "Opérateur : Oui (depuis XXXX)" ou "Non"
  - Liste des années si historique présent
- Les champs `presence_categorie`, `nom_categorie`, mission, programme, programmes annexes restent inchangés

### index.html.erb (lignes 52-65)
- Remplacer le filtre `operateur_operateur_n_in` + `operateur_operateur_n_null` par un simple tag group `operateur_actif_in` Oui/Non

---

## Étape 10 — Exports XLSX

### index.xlsx.axlsx
- Headers : remplacer les 4 colonnes "Opérateur YYYY" par "Opérateur actif" + "Années opérateur"
- `array_operateur` : utiliser `organisme.operateur_actif` et `operateur.toutes_annees.join(', ')`
- Ajuster le nombre de colonnes (57→55) et les plages de style

### show.xlsx.axlsx
- Mêmes changements que index.xlsx.axlsx

---

## Étape 11 — ActiveAdmin

**Fichier :** `app/admin/operateurs.rb`

- Remplacer `permit_params` : retirer les 4 booléens, ajouter `annees: []`

---

## Étape 12 — Fixtures et tests

### test/fixtures/operateurs.yml
- Remplacer `operateur_n/n1/n2` par `annees: [2023, 2024]`

### test/models/operateur_test.rb
- Ajouter des tests pour `operateur_pour_annee?`, `toutes_annees`, `activer!`, `desactiver!`

---

## Fichiers impactés (résumé)

| # | Fichier | Type de changement |
|---|---------|-------------------|
| 1 | `db/migrate/XXXXXX_refactor_operateur_annees.rb` | Création |
| 2 | `app/models/operateur.rb` | Modification majeure |
| 3 | `app/models/organisme.rb` | Modification mineure |
| 4 | `app/controllers/operateurs_controller.rb` | Modification majeure |
| 5 | `app/controllers/organismes_controller.rb` | Modification (simplification filtres) |
| 6 | `app/controllers/chiffres_controller.rb` | Modification mineure |
| 7 | `app/views/operateurs/_form.html.erb` | Réécriture du bloc années |
| 8 | `app/javascript/controllers/form_controller.js` | Modification sélecteurs |
| 9 | `app/views/organismes/show.html.erb` | Modification bloc opérateur |
| 10 | `app/views/organismes/index.html.erb` | Modification filtres |
| 11 | `app/views/organismes/index.xlsx.axlsx` | Modification colonnes export |
| 12 | `app/views/organismes/show.xlsx.axlsx` | Modification colonnes export |
| 13 | `app/admin/operateurs.rb` | Modification params |
| 14 | `test/fixtures/operateurs.yml` | Mise à jour |
| 15 | `test/models/operateur_test.rb` | Ajout tests |

---

## Vérification

1. Lancer la migration et vérifier que les données existantes sont correctement converties
2. Vérifier que la page index organismes charge sans erreur et que le filtre Opérateur Oui/Non fonctionne
3. Vérifier l'export XLSX avec les nouvelles colonnes
4. Tester le formulaire opérateur (création, modification, désactivation)
5. Vérifier que `select_exercice` dans chiffres retourne les bonnes valeurs
6. Lancer `rails test`
