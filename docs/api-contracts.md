# API Contracts & Routes — OPERA

> Generated: 2026-02-24 | Scan level: deep

## Base Configuration

- **Application scope:** All routes under `/opera`
- **Root redirect:** `GET /` → redirects to `/opera`
- **Authentication:** Devise (users + admin_users)
- **Authorization:** Role-based via `user.statut` (2B2O, Controleur, Bureau Sectoriel)

## Role Definitions

| Role | Description | Access Level |
|------|-------------|-------------|
| **2B2O** | Administrator | Full CRUD, imports, approvals |
| **Controleur** | Financial controller | Own organisms, budget creation, modification requests |
| **Bureau Sectoriel** | Sectoral office | Read-only across sector |

## Routes Catalog

### Authentication

| Method | Path | Controller#Action | Auth | Description |
|--------|------|-------------------|------|-------------|
| GET | `/opera/connexion` | sessions#new | No | Login page |
| POST | `/opera/connexion` | sessions#create | No | Authenticate (by statut + nom) |
| DELETE | `/opera/logout` | sessions#destroy | Yes | Sign out |
| GET | `/opera/admin/login` | admin/sessions#new | No | Admin login |

### Dashboard & Static Pages

| Method | Path | Controller#Action | Auth | Description |
|--------|------|-------------------|------|-------------|
| GET | `/opera` | pages#index | Yes | Dashboard with organism overview |
| GET | `/opera/mentions-legales` | pages#mentions_legales | Yes | Legal notices |
| GET | `/opera/donnees-personnelles` | pages#donnees_personnelles | Yes | Privacy policy |
| GET | `/opera/accessibilite` | pages#accessibilite | Yes | Accessibility statement |
| GET | `/opera/plan` | pages#plan | Yes | Site map |

### Organismes (Primary Resource)

| Method | Path | Controller#Action | Auth | Formats | Description |
|--------|------|-------------------|------|---------|-------------|
| GET | `/opera/organismes` | organismes#index | Yes | HTML, XLSX | List with Ransack search |
| GET | `/opera/organismes/:id` | organismes#show | Yes | HTML | Detail view + modifications |
| GET | `/opera/organismes/new` | organismes#new | 2B2O | HTML | Create form |
| POST | `/opera/organismes` | organismes#create | 2B2O | HTML | Create organism |
| GET | `/opera/organismes/:id/edit` | organismes#edit | 2B2O/Ctrl | HTML | Multi-step edit form |
| PATCH | `/opera/organismes/:id` | organismes#update | 2B2O/Ctrl | HTML | Update with modification tracking |
| DELETE | `/opera/organismes/:id` | organismes#destroy | 2B2O | HTML | Delete organism |
| POST | `/opera/search_organismes` | organismes#search_organismes | Yes | Turbo Stream | Real-time search |
| POST | `/opera/import_organismes` | organismes#import_organismes | 2B2O | HTML | Bulk import from XLSX |
| GET | `/opera/organismes/:id/enquete` | organismes#enquete | Yes | HTML | Survey view for organism |

### Chiffres (Budget/Financial Data)

| Method | Path | Controller#Action | Auth | Formats | Description |
|--------|------|-------------------|------|---------|-------------|
| GET | `/opera/organismes/:id/chiffres` | chiffres#index | Yes | HTML, XLSX | Budgets for organism |
| GET | `/opera/organismes/:id/restitutions` | chiffres#restitutions | Yes | HTML | Historical budget summary |
| GET | `/opera/chiffres/new` | chiffres#new | Ctrl | HTML | New budget form |
| POST | `/opera/chiffres` | chiffres#create | Ctrl | HTML | Create budget entry |
| GET | `/opera/chiffres/:id` | chiffres#show | Yes | HTML, PDF | View budget detail |
| GET | `/opera/chiffres/:id/edit` | chiffres#edit | Ctrl | HTML | Multi-step edit form |
| PATCH | `/opera/chiffres/:id` | chiffres#update | Ctrl | HTML | Update budget |
| DELETE | `/opera/chiffres/:id` | chiffres#destroy | Ctrl | HTML | Delete draft budget |
| POST | `/opera/chiffres/:id/duplicate` | chiffres#duplicate | Ctrl | HTML | Duplicate budget entry |
| GET | `/opera/budgets` | chiffres#budgets | Yes | HTML | Budget dashboard by risk |
| GET | `/opera/budgets-historique` | chiffres#historique | Yes | HTML, XLSX | Advanced search/export |
| GET | `/opera/suivi-remplissage` | chiffres#suivi_remplissage | Yes | HTML | Completion tracking |
| POST | `/opera/show_dates` | chiffres#show_dates | Yes | Turbo Stream | Fiscal year tabs |
| POST | `/opera/select_comptabilite` | chiffres#select_comptabilite | No | JSON | Get accounting type |
| POST | `/opera/select_exercice` | chiffres#select_exercice | No | JSON | Get operator info |
| POST | `/opera/update_phase` | chiffres#update_phase | Ctrl | HTML | Update budget phase |
| POST | `/opera/open_phase` | chiffres#open_phase | Ctrl | Turbo Stream | Phase modal |

### Operateurs

| Method | Path | Controller#Action | Auth | Description |
|--------|------|-------------------|------|-------------|
| GET | `/opera/operateurs` | operateurs#index | 2B2O | List operators |
| GET | `/opera/operateurs/new` | operateurs#new | 2B2O | New operator form |
| POST | `/opera/operateurs` | operateurs#create | 2B2O | Create operator |
| GET | `/opera/operateurs/:id/edit` | operateurs#edit | 2B2O | Edit operator |
| PATCH | `/opera/operateurs/:id` | operateurs#update | 2B2O | Update operator |
| POST | `/opera/import_operateurs` | operateurs#import | 2B2O | Bulk import XLSX |

### Ministeres

| Method | Path | Controller#Action | Auth | Description |
|--------|------|-------------------|------|-------------|
| GET | `/opera/ministeres` | ministeres#index | 2B2O | List ministries |
| POST | `/opera/ministeres` | ministeres#create | 2B2O | Create ministry |
| GET | `/opera/ministeres/:id/edit` | ministeres#edit | 2B2O | Edit ministry |
| PATCH | `/opera/ministeres/:id` | ministeres#update | 2B2O | Update ministry |
| POST | `/opera/import_ministeres` | ministeres#import | 2B2O | Bulk import XLSX |

### Missions & Programmes

| Method | Path | Controller#Action | Auth | Formats | Description |
|--------|------|-------------------|------|---------|-------------|
| GET | `/opera/missions` | missions#index | 2B2O | HTML | List missions |
| POST | `/opera/import_missions` | missions#import_missions | 2B2O | HTML | Bulk import XLSX |
| POST | `/opera/select_mission` | missions#select_mission | No | JSON | Get mission for program |

### Modifications (Change Tracking)

| Method | Path | Controller#Action | Auth | Formats | Description |
|--------|------|-------------------|------|---------|-------------|
| GET | `/opera/modifications` | modifications#index | Ctrl/2B2O | HTML | Dashboard by status |
| PATCH | `/opera/modifications/:id` | modifications#update | 2B2O | HTML | Approve/reject |
| DELETE | `/opera/modifications/:id` | modifications#destroy | Ctrl/2B2O | HTML | Cancel request |
| POST | `/opera/filter_modifications` | modifications#filter_modifications | Ctrl/2B2O | Turbo Stream | Filter by organism |
| POST | `/opera/open_modal` | modifications#open_modal | Ctrl/2B2O | Turbo Stream | Rejection modal |

### Enquetes (Surveys)

| Method | Path | Controller#Action | Auth | Formats | Description |
|--------|------|-------------------|------|---------|-------------|
| GET | `/opera/enquete_reponses` | enquete_reponses#index | No | HTML, XLSX | Survey results |
| GET | `/opera/enquete_reponses/:id` | enquete_reponses#show | No | HTML, PDF | Individual response |
| GET | `/opera/enquete_reponses/new` | enquete_reponses#new | 2B2O | HTML | Stats dashboard |
| POST | `/opera/import_reponses` | enquete_reponses#import | 2B2O | HTML | Bulk import XLSX |
| DELETE | `/opera/enquete_reponses/:id` | enquete_reponses#destroy | 2B2O | HTML | Delete survey year |
| GET | `/opera/enquete_questions` | enquete_questions#index | 2B2O | HTML | Questions by year |

### Documents

| Method | Path | Controller#Action | Auth | Description |
|--------|------|-------------------|------|-------------|
| GET | `/opera/control_documents` | control_documents#index | Yes | List documents |
| GET | `/opera/control_documents/new` | control_documents#new | Yes | Upload form |
| POST | `/opera/control_documents` | control_documents#create | Yes | Upload document |
| GET | `/opera/control_documents/:id/edit` | control_documents#edit | Yes | Edit document |
| DELETE | `/opera/control_documents/:id` | control_documents#destroy | Yes | Delete document |
| GET | `/opera/objectifs_contrats` | objectifs_contrats#index | Yes | List objectives |
| GET | `/opera/objectifs_contrats/new` | objectifs_contrats#new | Yes | Upload form |
| POST | `/opera/objectifs_contrats` | objectifs_contrats#create | Yes | Create objective |
| GET | `/opera/objectifs_contrats/:id/edit` | objectifs_contrats#edit | Yes | Edit objective |
| DELETE | `/opera/objectifs_contrats/:id` | objectifs_contrats#destroy | Yes | Delete objective |

### Users & AJAX Helpers

| Method | Path | Controller#Action | Auth | Formats | Description |
|--------|------|-------------------|------|---------|-------------|
| GET | `/opera/users` | users#index | No | HTML | User management |
| POST | `/opera/import_users` | users#import | No | HTML | Bulk import users |
| POST | `/opera/select_nom` | users#select_nom | No | JSON | Get users by role |

### Error Pages

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| ALL | `/opera/404` | errors#error_404 | Not found |
| ALL | `/opera/500` | errors#error_500 | Server error |
| ALL | `/opera/503` | errors#error_503 | Service unavailable |
| ALL | `/opera/*path` | errors#error_404 | Catch-all → 404 |

### ActiveAdmin

All admin routes are mounted under `/opera/admin/` via `ActiveAdmin.routes(self)`, providing CRUD for all registered resources (16 admin resources).

## Export Capabilities

| Format | Endpoints | Library |
|--------|-----------|---------|
| HTML | All | Rails views |
| XLSX | organismes#index, chiffres#index, chiffres#historique, enquete_reponses#index | caxlsx_rails |
| PDF | chiffres#show, enquete_reponses#show | WickedPDF / Ferrum |
| JSON | select_nom, select_mission, select_comptabilite, select_exercice | jbuilder |
| Turbo Stream | search_organismes, show_dates, filter_modifications, open_modal, open_phase | turbo-rails |

## Import Endpoints (Bulk XLSX Upload)

| Endpoint | Model | Required Role |
|----------|-------|---------------|
| POST `/import_users` | User | — |
| POST `/import_organismes` | Organisme | 2B2O |
| POST `/import_operateurs` | Operateur | 2B2O |
| POST `/import_ministeres` | Ministere | 2B2O |
| POST `/import_missions` | Mission | 2B2O |
| POST `/import_reponses` | EnqueteReponse | 2B2O |
