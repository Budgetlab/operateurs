# Architecture — OPERA

> Generated: 2026-02-24 | Scan level: deep

## Executive Summary

OPERA is a monolithic Ruby on Rails 8.1 web application serving the French government for managing public organisms (agencies, operators) and their budgetary data. It follows a classical server-rendered MVC architecture enhanced with Hotwire (Turbo + Stimulus) for progressive interactivity. The application uses PostgreSQL, deploys on Google Cloud Run, and implements the DSFR (Design System de l'État) for UI compliance.

## Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Language | Ruby | 3.4.8 |
| Framework | Ruby on Rails | 8.1.1+ |
| Database | PostgreSQL | — (with unaccent extension) |
| Web Server | Puma | 6.4.x |
| Frontend | Hotwire (Turbo + Stimulus) | — |
| Design System | DSFR | v1.12.1 |
| CSS | Sass (sassc-rails) | — |
| JS Management | importmap-rails | — |
| Auth | Devise | 4.9.x |
| Admin | ActiveAdmin | 3.4.x |
| Cloud | Google Cloud Run | — |
| Storage | Google Cloud Storage | — |
| CI/CD | GitHub Actions + Cloud Build | — |

## Architecture Pattern

**Monolithic MVC** with server-side rendering and progressive enhancement.

```
┌─────────────────────────────────────────────────────┐
│                    Browser (DSFR)                    │
│         Turbo Drive + Stimulus Controllers           │
└──────────────────────┬──────────────────────────────┘
                       │ HTTP (HTML/Turbo Stream/JSON)
┌──────────────────────▼──────────────────────────────┐
│                   Puma (port 8080)                   │
├─────────────────────────────────────────────────────┤
│                    Rails Router                      │
│              (scoped under /opera)                   │
├──────────┬──────────┬───────────┬───────────────────┤
│ Devise   │ Active   │ App       │ Error             │
│ Auth     │ Admin    │ Controllers│ Handling          │
├──────────┴──────────┴───────────┴───────────────────┤
│                   Models (ActiveRecord)              │
│         Organismes, Chiffres, Users, etc.            │
├─────────────────────────────────────────────────────┤
│              PostgreSQL (Cloud SQL)                  │
│         + Active Storage (GCS blobs)                 │
└─────────────────────────────────────────────────────┘
```

## Application Structure

```
operateurs/
├── app/
│   ├── admin/              # 16 ActiveAdmin resources
│   ├── assets/
│   │   ├── fonts/          # Marianne & Spectral (DSFR fonts)
│   │   ├── images/         # DSFR artwork, pictograms, favicon
│   │   └── stylesheets/    # application.scss, dsfr.scss, pdf.scss
│   ├── channels/           # ActionCable (unused)
│   ├── controllers/        # 15 controllers + 1 concern
│   │   └── concerns/       # Authentication concern
│   ├── helpers/            # ApplicationHelper (20+ view helpers)
│   ├── javascript/
│   │   ├── controllers/    # 11 Stimulus controllers
│   │   └── custom/         # DSFR JS modules
│   ├── jobs/               # UrlToPdfJob
│   ├── mailers/            # ApplicationMailer (base)
│   ├── models/             # 18 ActiveRecord models
│   └── views/              # ERB templates (~120 files)
│       ├── layouts/        # 5 layouts (app, header, footer, pdf, errors)
│       ├── devise/         # Auth views
│       └── [resources]/    # Resource-specific views
├── config/
│   ├── environments/       # dev, test, production
│   ├── initializers/       # Devise, ActiveAdmin, Pagy, Ransack, WickedPDF
│   ├── locales/            # fr.yml, en.yml, devise.en.yml
│   ├── routes.rb           # All routes under /opera scope
│   ├── database.yml        # PostgreSQL (Cloud SQL in prod)
│   ├── storage.yml         # GCS in production
│   └── importmap.rb        # JS dependencies
├── db/
│   ├── schema.rb           # 16 tables, 40 migrations
│   └── seeds.rb            # Initial data
├── test/                   # Minitest + Capybara + Selenium
├── Dockerfile              # Ruby 3.4 + Node 18 + Chrome
├── cloudbuild.yaml         # GCP Cloud Build pipeline
├── Procfile                # Puma configuration
└── .github/workflows/      # CI: tests + security audit
```

## Domain Architecture

### Core Domain: Organism Management

The application manages the lifecycle and data of French public organisms:

```
Ministères ←──────── OrganismeMinistères ────────→ Organismes
                                                      │
                     OrganismeRattachements ──────────┤ (self-referential)
                                                      │
Programmes ←── Missions ←── Opérateurs ──────────────┤
     │                                                │
     └── OpérateurProgrammes                          │
                                                      │
                     Chiffres (budgets) ──────────────┤
                     Modifications ───────────────────┤
                     ControlDocuments ────────────────┤
                     ObjectifsContrats ───────────────┤
                     EnquêteRéponses ─────────────────┘
```

### Functional Domains

1. **Organism Registry** — CRUD for public organisms with governance, control, and classification data
2. **Budgetary Cycle** — Multi-phase budget tracking (Budget initial → Budget rectificatif → Compte financier) with employment, credits, treasury, and accounting data
3. **Change Management** — Modification request workflow (En attente → validée/refusée) for controlled organism updates
4. **Survey System** — Annual surveys (enquêtes CIB-CIC) with question management and response aggregation
5. **Document Management** — Control documents and contract objectives (COP/COM) with file attachments
6. **Reference Data** — Ministries, programs, missions, operators managed via import

## Authentication & Authorization

### Two-tier Authentication
1. **User authentication** (Devise): Login by `statut` (role) + `nom` (username) + password
2. **Admin authentication** (Devise + ActiveAdmin): Separate admin users for back-office

### Role-based Authorization (Custom)
Authorization implemented via `current_user.statut` checks in controllers:

| Role | Scope | Capabilities |
|------|-------|-------------|
| **2B2O** | Global | Full CRUD, imports, modification approval, survey management |
| **Controleur** | Own organisms + family | Budget creation/editing, modification requests, organism editing |
| **Bureau Sectoriel** | Sector-wide read | Read-only access to organisms and budgets |

### Family-based Filtering
Organisms are grouped by `famille`. Controllers filter data based on the user's family assignment, with special rules (e.g., CBCM MEN-MESRI sees "Universités" family).

## Data Flow

### Budget Lifecycle
```
Controleur creates budget (phase: Budget initial)
    → Fills employment data (emplois)
    → Fills credits data (AE/CP)
    → Fills treasury data
    → Fills accounting data (if comptabilité budgétaire)
    → Adds analysis/commentary
    → Submits → statut: "Soumis"

2B2O reviews
    → Phase transitions: Budget initial → Budget rectificatif → Compte financier
    → Can open/close phases

Exports: XLSX (bulk), PDF (individual), Charts (Highcharts)
```

### Modification Workflow
```
Controleur edits organism field
    → System captures: field, old_value, new_value
    → Creates Modification record (statut: "En attente")

2B2O reviews
    → Approve: applies change to organism, statut → "validée"
    → Reject: adds comment, statut → "refusée"
```

### Data Import Pipeline
```
Admin uploads XLSX file
    → Roo gem parses spreadsheet
    → Model.import(file) method processes rows
    → Creates/updates records with boolean conversion
    → Handles relationships (co-tutelles, programs, missions)
```

## Deployment Architecture

```
┌─────────────────────────────────────────┐
│           GitHub (main branch)          │
└──────────────┬──────────────────────────┘
               │ push/PR
┌──────────────▼──────────────────────────┐
│        GitHub Actions CI                │
│  ├── Tests (Minitest + PostgreSQL 11)   │
│  ├── Bundle Audit (gem vulnerabilities) │
│  └── Brakeman (static security scan)   │
└──────────────┬──────────────────────────┘
               │ on success
┌──────────────▼──────────────────────────┐
│        Google Cloud Build               │
│  ├── Docker build (Ruby 3.4 + Chrome)   │
│  │   └── RAILS_MASTER_KEY from Secrets  │
│  ├── Push image to GCR                  │
│  └── Run db:migrate via Cloud SQL Proxy │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│        Google Cloud Run                 │
│  ├── Region: europe-west1              │
│  ├── Service: opera-test               │
│  ├── Port: 8080                        │
│  └── Health: /up endpoint              │
├─────────────────────────────────────────┤
│        Google Cloud SQL                 │
│  ├── Instance: budgetlab               │
│  ├── Database: opera-test (PostgreSQL)  │
│  └── Connection: Unix socket            │
├─────────────────────────────────────────┤
│        Google Cloud Storage             │
│  ├── Bucket: opera-bucket              │
│  └── Service account: operaservice@    │
├─────────────────────────────────────────┤
│        Google Secret Manager            │
│  └── opera-secret (RAILS_MASTER_KEY)   │
└─────────────────────────────────────────┘
```

## Security Considerations

- **Credentials:** Rails encrypted credentials for DB password and GCS service account
- **Secrets:** RAILS_MASTER_KEY stored in Google Secret Manager
- **Database:** Cloud SQL Unix socket connection (no TCP exposure)
- **Auth:** Devise with bcrypt (12 stretches), Turbo-compatible status codes
- **Admin:** Separate admin_users table with independent Devise configuration
- **CI Security:** Brakeman static analysis + bundler-audit on every PR
- **Filtered params:** Passwords excluded from ActiveAdmin display/export
- **CSRF:** Rails default CSRF protection + Turbo Stream headers

## Testing Strategy

| Type | Framework | Location |
|------|-----------|----------|
| Unit tests | Minitest | test/models/ |
| System tests | Capybara + Selenium | test/system/ |
| Fixtures | YAML | test/fixtures/ |
| CI | GitHub Actions | PostgreSQL 11 service container |

## Key Configuration Files

| File | Purpose |
|------|---------|
| `config/routes.rb` | All routes scoped under `/opera` |
| `config/database.yml` | PostgreSQL per environment |
| `config/storage.yml` | GCS for production, disk for dev |
| `config/importmap.rb` | JS dependencies (Highcharts, Flatpickr, jsPDF) |
| `config/initializers/devise.rb` | Auth settings |
| `config/initializers/active_admin.rb` | Admin panel config |
| `config/initializers/pagy.rb` | Pagination setup |
| `config/initializers/ransack.rb` | Search config |
| `config/initializers/wicked_pdf.rb` | PDF generation |
| `config/locales/fr.yml` | French translations |
