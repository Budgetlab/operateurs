# Project Overview — OPERA

> Generated: 2026-02-24 | Scan level: deep

## Purpose

**OPERA** is a French government web application for managing and monitoring public organisms (operators, agencies, and institutions). It serves the Direction du Budget (Budget Directorate) for tracking organizational data, budgetary cycles, governance structures, and regulatory compliance of state-controlled entities.

## Key Features

1. **Organism Registry** — Comprehensive management of public organisms including identity, governance, control structures, legal status, and ministerial relationships
2. **Budgetary Cycle Tracking** — Multi-phase budget management (Budget initial → Budget rectificatif → Compte financier) with detailed employment, credits, treasury, and accounting data
3. **Financial Analysis** — Automated risk assessment, solvency indicators, treasury evolution, and comparative analytics with Highcharts visualizations
4. **Change Management** — Controlled modification workflow (request → approval/rejection) for organism data updates
5. **Annual Surveys** — CIB-CIC survey management with question administration, response collection, and statistical aggregation
6. **Document Management** — Control documents and contract objectives (COP/COM) with file attachments via Active Storage
7. **Data Import/Export** — Bulk XLSX import for all reference data; XLSX, PDF, and chart exports for reporting
8. **Admin Panel** — ActiveAdmin back-office for direct database management

## Quick Reference

| Attribute | Value |
|-----------|-------|
| **Type** | Monolith web application |
| **Framework** | Ruby on Rails 8.1 |
| **Language** | Ruby 3.4.8 |
| **Database** | PostgreSQL (Cloud SQL) |
| **Frontend** | Hotwire (Turbo + Stimulus) |
| **Design System** | DSFR (Design System de l'État) |
| **Authentication** | Devise (role-based: 2B2O, Controleur, Bureau Sectoriel) |
| **Admin** | ActiveAdmin 3.4 |
| **Deployment** | Google Cloud Run (europe-west1) |
| **CI/CD** | GitHub Actions + Google Cloud Build |
| **Entry Point** | `config.ru` → routes scoped under `/opera` |

## Domain Model (Core Entities)

| Entity | Description | Records |
|--------|-------------|---------|
| **Organismes** | Public organisms (agencies, operators) | Primary entity |
| **Chiffres** | Budget/financial data per organism per fiscal year | ~80 financial columns |
| **Ministeres** | Government ministries | Reference data |
| **Programmes** | Budget programs (identified by number) | Reference data |
| **Missions** | Budget missions linked to programs | Reference data |
| **Operateurs** | Links organisms to programs as operators | Join entity |
| **Modifications** | Change request tracking | Workflow entity |
| **EnqueteReponses** | Survey responses (JSONB) | Per organism per year |
| **ControlDocuments** | Control documents with file attachments | Per organism |
| **ObjectifsContrats** | Contract objectives (COP/COM) | Per organism |
| **Users** | Application users with roles | 3 roles |
| **AdminUsers** | ActiveAdmin administrators | Separate auth |

## User Roles

| Role | French Name | Access |
|------|------------|--------|
| **2B2O** | Bureau de la 2ème sous-direction du Budget, de la performance et des opérateurs | Full admin: all CRUD, imports, approvals |
| **Controleur** | Contrôleur budgétaire | Own organisms: budget creation, modification requests |
| **Bureau Sectoriel** | Bureau sectoriel | Read-only: sector-wide consultation |

## Technology Summary

- **Backend:** Rails 8.1 MVC with Devise auth and ActiveAdmin
- **Frontend:** Server-rendered ERB with Turbo Streams for partial updates, Stimulus for interactivity
- **Charts:** Highcharts 11.4.8 (14 chart types for financial visualization)
- **PDF:** WickedPDF (server) + jsPDF (client) + Ferrum (background)
- **Search:** Ransack with accent-insensitive autocomplete
- **Pagination:** Pagy with custom DSFR renderer
- **i18n:** French default locale with rails-i18n
- **Files:** Active Storage → Google Cloud Storage
