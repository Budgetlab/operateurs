# Data Models — OPERA

> Generated: 2026-02-24 | Scan level: deep

## Overview

The OPERA application uses PostgreSQL with the `unaccent` extension enabled. The schema contains **16 tables** organized around public organism management, budgetary tracking, surveys, and user administration.

## Entity Relationship Summary

```
Users ──────────┬──> Chiffres
                ├──> Modifications
                ├──> ControlDocuments
                ├──> ObjectifsContrats
                └──> Organismes (as bureau_id, controleur_id)

Organismes ─────┬──> Chiffres
                ├──> Modifications
                ├──> ControlDocuments
                ├──> ObjectifsContrats
                ├──> Operateurs
                ├──> OrganismeMinisteres ──> Ministeres
                ├──> OrganismeRattachements ──> Organismes (self-ref)
                └──> EnqueteReponses

Programmes ─────┬──> Missions ──> Operateurs
                └──> OperateurProgrammes ──> Operateurs

Enquetes ───────┬──> EnqueteQuestions
                └──> EnqueteReponses
```

## Tables

### users
Authentication and role management via Devise.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK | |
| email | string | unique, not null | Login email |
| encrypted_password | string | not null | Devise password hash |
| nom | string | | User display name |
| statut | string | | Role: 2B2O, Controleur, Bureau Sectoriel |
| sign_in_count | integer | default 0 | Trackable sign-in counter |
| current_sign_in_at | datetime | | Last sign-in timestamp |
| current_sign_in_ip | string | | Last sign-in IP |
| last_sign_in_at | datetime | | Previous sign-in timestamp |
| last_sign_in_ip | string | | Previous sign-in IP |
| remember_created_at | datetime | | Devise rememberable |
| reset_password_token | string | unique | Devise recoverable |
| reset_password_sent_at | datetime | | Token sent timestamp |

**Indexes:** email (unique), reset_password_token (unique)

### admin_users
Separate Devise-authenticated admin users for ActiveAdmin.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK | |
| email | string | unique, not null | Admin email |
| encrypted_password | string | not null | Devise password hash |
| remember_created_at | datetime | | |
| reset_password_token | string | unique | |
| reset_password_sent_at | datetime | | |

### organismes
Core entity — represents public organisms (agencies, institutions).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK | |
| nom | string | | Full name |
| acronyme | string | | Acronym |
| siren | string | | SIREN identification number |
| nature | string | | Legal nature (EPA, EPIC, etc.) |
| famille | string | | Family classification |
| statut | string | | Status (valide, en attente, etc.) |
| etat | string | | State (Actif, Inactif, etc.) |
| date_creation | date | | Creation date |
| date_dissolution | date | | Dissolution date |
| date_previsionnelle_dissolution | date | | Planned dissolution date |
| effet_dissolution | string | | Dissolution effect |
| texte_institutif | string | | Founding legal text |
| commentaire | string | | Free text comment |
| ministere_id | bigint | FK | Primary ministry |
| bureau_id | bigint | FK → users | Assigned bureau user |
| controleur_id | bigint | FK → users, not null | Assigned controller user |
| **Governance columns** | | | |
| admin_db_present | boolean | | DB administrator present |
| admin_db_fonction | string | | DB administrator function |
| admin_preca | boolean | | PRECA administrator |
| agent_comptable_present | boolean | | Accounting agent present |
| comite_audit | boolean | | Audit committee exists |
| autorite_approbation | string | | Approval authority |
| delegation_approbation | boolean | | Delegated approval |
| tutelle_financiere | boolean | | Financial supervision |
| **Control columns** | | | |
| presence_controle | boolean | | Control presence |
| nature_controle | string | | Control nature |
| autorite_controle | string | | Control authority |
| controleur_ca | boolean | | CA controller |
| controleur_preca | boolean | | PRECA controller |
| document_controle_present | boolean | | Control document present |
| arrete_controle | string | | Control decree |
| arrete_nomination | string | | Nomination decree |
| arrete_interdiction_odac | string | | ODAC prohibition decree |
| texte_reglementaire_controle | string | | Regulatory control text |
| texte_soumission_controle | string | | Control submission text |
| **Accounting columns** | | | |
| comptabilite_budgetaire | string | | Budgetary accounting type |
| degre_gbcp | string | | GBCP degree |
| gbcp_1 | boolean | | GBCP level 1 |
| gbcp_3 | boolean | | GBCP level 3 |
| **Classification flags** | | | |
| apu | boolean | | Public administration unit |
| odac_n / odac_n1 | boolean | | ODAC current/previous year |
| odal_n / odal_n1 | boolean | | ODAL current/previous year |
| ciassp_n / ciassp_n1 | boolean | | CIASSP current/previous year |
| taux_cadrage_n / taux_cadrage_n1 | float | | Framing rate |

**Indexes:** bureau_id, controleur_id, ministere_id
**Foreign keys:** ministere_id → ministeres, bureau_id → users, controleur_id → users

### chiffres
Budget and financial data — the most data-rich table (~80 columns).

| Column Group | Key Columns | Type | Description |
|-------------|-------------|------|-------------|
| **Identity** | organisme_id, user_id, exercice_budgetaire, type_budget, phase, statut | various | Budget identification |
| **Employment** | emplois_plafond, emplois_total, emplois_titulaires, emplois_contractuels, emplois_schema, emplois_hors_plafond, emplois_non_remuneres, emplois_autre_entite, emplois_charges_personnel, emplois_depenses_personnel, emplois_cout_total, emplois_cout_investissements, emplois_*_montant, emplois_*_prenotifie, emplois_plafond_rappel | float | Workforce and personnel costs |
| **Credits** | credits_ae_*, credits_cp_*, credits_subvention_*, credits_financements_*, credits_fiscalite_affectee, credits_recettes_*, credits_restes_a_payer | float | Appropriations (AE) and payment credits (CP) |
| **Treasury** | tresorerie_finale, tresorerie_variation, tresorerie_min/max, tresorerie_min/max_date, tresorerie_*_flechee, tresorerie_*_non_flechee | float/date | Cash flow and treasury position |
| **Accounting** | comptabilite_budgetaire, charges_fonctionnement, charges_intervention, charges_non_decaissables, produits_*, capacite_autofinancement, fonds_roulement_* | float/boolean | Accrual accounting data |
| **Resources** | ressources_financement_etat, ressources_autres, ressources_total, decaissements_*, encaissements_* | float | Funding sources and cash flows |
| **Analysis** | commentaire, commentaire_annexe, risque_insolvabilite, operateur | string/boolean | Financial analysis and risk |

**Foreign keys:** organisme_id → organismes, user_id → users

### ministeres
Government ministries.

| Column | Type | Description |
|--------|------|-------------|
| id | bigint | PK |
| nom | string | Ministry name |

### programmes
Budget programs (identified by number).

| Column | Type | Description |
|--------|------|-------------|
| id | bigint | PK |
| numero | integer | Program number |
| nom | string | Program name |
| statut | string | Default "actif" |

### missions
Budget missions linked to programs.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK | |
| nom | string | | Mission name |
| programme_id | bigint | FK, not null | Parent program |
| statut | string | default "actif" | |

### operateurs
Links organisms to programs/missions as operators.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK | |
| organisme_id | bigint | FK, not null | Linked organism |
| programme_id | bigint | FK, not null | Linked program |
| mission_id | bigint | FK, not null | Linked mission |
| operateur_nf | boolean | | Operator in final year |
| operateur_n | boolean | | Operator current year |
| operateur_n1 | boolean | | Operator year N+1 |
| operateur_n2 | boolean | | Operator year N+2 |
| presence_categorie | boolean | | Category assigned |
| nom_categorie | string | | Category name |

### operateur_programmes
Join table for operators and annexed programs.

| Column | Type | Constraints |
|--------|------|-------------|
| operateur_id | bigint | FK, not null |
| programme_id | bigint | FK, not null |

### organisme_ministeres
Join table for organisms and co-supervising ministries.

| Column | Type | Constraints |
|--------|------|-------------|
| organisme_id | bigint | FK, not null |
| ministere_id | bigint | FK, not null |

### organisme_rattachements
Self-referential join — organism-to-organism attachments.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| organisme_id | bigint | FK, not null | Source organism |
| organisme_destination_id | bigint | FK → organismes, not null | Destination organism |

### modifications
Change request tracking system.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK | |
| organisme_id | bigint | FK, not null | Target organism |
| user_id | bigint | FK, not null | Requesting user |
| champ | string | | Field name changed |
| nom | string | | Display label |
| ancienne_valeur | string | | Old value |
| nouvelle_valeur | string | | New value |
| statut | string | | En attente / validée / refusée |
| commentaire | string | | Rejection reason |

### control_documents
Control documents with file attachments (Active Storage).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK | |
| organisme_id | bigint | FK, not null | Linked organism |
| user_id | bigint | FK, not null | Uploading user |
| name | string | | Document name |
| signature_date | date | | Signature date |

**Attachment:** `has_one_attached :file`

### objectifs_contrats
Contract objectives (COP/COM) with file attachments.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK | |
| organisme_id | bigint | FK, not null | Linked organism |
| user_id | bigint | FK, not null | Creating user |
| nom | string | | Objective name |
| debut | integer | | Start year |
| fin | integer | | End year |

**Attachment:** `has_one_attached :file`

### enquetes
Survey years.

| Column | Type | Constraints |
|--------|------|-------------|
| id | bigint | PK |
| annee | integer | not null |

**Attachment:** `has_one_attached :file`

### enquete_questions
Survey questions linked to a survey year.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK | |
| enquete_id | bigint | FK, not null | Parent survey |
| numero | integer | | Question number |
| nom | text | | Question text |

### enquete_reponses
Survey responses stored as JSONB.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK | |
| enquete_id | bigint | FK, not null | Parent survey |
| organisme_id | bigint | FK, not null | Responding organism |
| reponses | jsonb | default {} | Question ID → answer mapping |

### Active Storage Tables
Standard Rails Active Storage tables for file management:
- `active_storage_blobs` — File metadata and storage keys
- `active_storage_attachments` — Polymorphic join to records
- `active_storage_variant_records` — Image variant tracking

### active_admin_comments
Standard ActiveAdmin comments for admin audit trail.

## Migration History

40 migrations spanning from 2023-06-14 to 2026-02-16, covering:
- Initial Devise user setup
- Core entity creation (organismes, programmes, missions, etc.)
- Financial data model (chiffres) with iterative column additions
- Survey system (enquetes, questions, responses)
- Modification tracking system
- Active Storage integration
- Field additions for governance, control, and classification data
