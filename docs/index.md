# OPERA — Project Documentation Index

> Generated: 2026-02-24 | Deep Scan | Ruby on Rails 8.1

## Project Overview

- **Type:** Monolith web application
- **Primary Language:** Ruby 3.4.8
- **Framework:** Ruby on Rails 8.1
- **Architecture:** MVC monolithique avec Hotwire (Turbo + Stimulus)
- **Design System:** DSFR (Design System de l'État Français)
- **Database:** PostgreSQL (Google Cloud SQL)
- **Deployment:** Google Cloud Run (europe-west1)

## Quick Reference

- **Entry Point:** `config.ru` → all routes under `/opera`
- **Admin Panel:** `/opera/admin/` (ActiveAdmin)
- **Authentication:** Devise (roles: 2B2O, Controleur, Bureau Sectoriel)
- **Tech Stack:** Rails 8.1, PostgreSQL, Hotwire, DSFR, Highcharts, WickedPDF
- **Tables:** 16 (core: organismes, chiffres, users, programmes, missions)
- **Controllers:** 15 + 1 concern
- **Models:** 18
- **Stimulus Controllers:** 11
- **View Templates:** ~120

## Generated Documentation

- [Project Overview](./project-overview.md) — Purpose, features, domain model, user roles
- [Architecture](./architecture.md) — Stack, patterns, domain architecture, deployment diagram
- [Source Tree Analysis](./source-tree-analysis.md) — Annotated directory tree, critical folders, entry points
- [Data Models](./data-models.md) — Database schema, 16 tables, relationships, column details
- [API Contracts & Routes](./api-contracts.md) — 60+ endpoints, auth requirements, export formats
- [UI Component Inventory](./component-inventory.md) — 11 Stimulus controllers, DSFR components, helpers
- [Development Guide](./development-guide.md) — Setup, testing, commands, dev patterns
- [Deployment Guide](./deployment-guide.md) — Docker, Cloud Build, CI/CD, infrastructure

## Existing Documentation

- [README.md](../README.md) — Default Rails README (minimal content)
- [CI/CD Workflow](../.github/workflows/rubyonrails.yml) — GitHub Actions: tests + security audit
- [Usage Charter](../public/Charte_utilisation_OPERA.docx) — Application usage guidelines

## Getting Started

1. Install Ruby 3.4.8 and PostgreSQL
2. Run `bundle install` to install dependencies
3. Run `bin/rails db:create db:schema:load db:seed` to setup the database
4. Run `bin/rails server` to start the development server
5. Access the application at `http://localhost:3000/opera`

For detailed instructions, see the [Development Guide](./development-guide.md).
