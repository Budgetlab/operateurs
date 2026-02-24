# Development Guide — OPERA

> Generated: 2026-02-24 | Scan level: deep

## Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Ruby | 3.4.8 | Specified in `.ruby-version` |
| PostgreSQL | 11+ | With `unaccent` extension |
| Node.js | 18.x | For asset compilation |
| Bundler | latest | Ruby dependency management |

## Installation

```bash
# Clone repository
git clone <repository-url>
cd operateurs

# Install Ruby dependencies
bundle install

# Create and setup database
bin/rails db:create
bin/rails db:schema:load
bin/rails db:seed

# Start development server
bin/rails server
# → http://localhost:3000/opera
```

## Environment Variables

Create a `.env` file at the project root:

```
PRODUCTION_DB_NAME=opera-test
PRODUCTION_DB_USERNAME=postgres
CLOUD_SQL_CONNECTION_NAME=<instance>
GOOGLE_PROJECT_ID=<project-id>
STORAGE_BUCKET_NAME=<bucket>
SERVICE_NAME=opera-test
```

For development, the database uses local PostgreSQL defaults (no env vars needed).

## Database

- **Development:** `operateurs_development` (local PostgreSQL)
- **Test:** `operateurs_test` (local PostgreSQL)
- **Production:** Cloud SQL via Unix socket

```bash
# Run migrations
bin/rails db:migrate

# Reset database
bin/rails db:reset

# Generate new migration
bin/rails generate migration AddFieldToModel field:type
```

## Running the Application

```bash
# Development server (port 3000)
bin/rails server
# Access at: http://localhost:3000/opera

# Rails console
bin/rails console

# Run specific rake task
bin/rake <task_name>
```

## Testing

```bash
# Run full test suite
bin/rake

# Run specific test file
bin/rails test test/models/organisme_test.rb

# Run system tests (requires Chrome/Selenium)
bin/rails test:system
```

### Test Stack
- **Framework:** Minitest (Rails default)
- **System tests:** Capybara + Selenium WebDriver
- **Fixtures:** YAML files in `test/fixtures/`
- **CI:** GitHub Actions with PostgreSQL 11 service container

## Build & Assets

```bash
# Precompile assets
bin/rails assets:precompile

# Clear asset cache
bin/rails assets:clobber
```

JavaScript dependencies are managed via `importmap-rails` — no npm/yarn needed for JS in development.

## Docker

```bash
# Build Docker image
docker build --build-arg MASTER_KEY=<your-master-key> -t opera .

# Run container
docker run -p 8080:8080 -e RAILS_MASTER_KEY=<key> opera
```

The Dockerfile includes:
- Ruby 3.4 base image
- Node.js 18.x
- Google Chrome (for PDF generation via Ferrum)
- Asset precompilation during build

## Code Quality & Security

```bash
# Security audit (gem vulnerabilities)
bundle exec bundle audit --update

# Static security analysis
bundle exec brakeman -q -w2

# Code style (RuboCop)
bundle exec rubocop
```

These checks run automatically on every push/PR via GitHub Actions.

## Key Development Patterns

### Authentication
- Users authenticate via `statut` (role) + `nom` (username) + password
- Admin users have separate Devise-backed authentication at `/opera/admin`
- Roles: 2B2O (admin), Controleur, Bureau Sectoriel

### Data Import
All bulk imports follow the same pattern:
```ruby
# In model
def self.import(file)
  spreadsheet = Roo::Spreadsheet.open(file.path)
  # Parse rows, create/update records
end
```

### XLSX Export
Uses caxlsx_rails in controllers:
```ruby
respond_to do |format|
  format.html
  format.xlsx { render xlsx: 'template', filename: 'export.xlsx' }
end
```

### PDF Generation
Two approaches:
1. **Server-side:** WickedPDF (wkhtmltopdf) for budget documents
2. **Client-side:** jsPDF + html2canvas (Stimulus controller) for survey exports
3. **Background:** Ferrum (headless Chrome) via UrlToPdfJob

### Search
Ransack provides advanced filtering:
```ruby
@q = Model.ransack(params[:q])
@records = @q.result
```

### Frontend Interactivity
Stimulus controllers handle all JS behavior — no jQuery or other frameworks:
- `form_controller.js` — Complex form validation
- `highcharts_controller.js` — Financial charts
- `search_controller.js` — Autocomplete search
- `session_controller.js` — Login form
- `tab_controller.js` — DSFR tab navigation

## Deployment

### CI/CD Pipeline
1. Push to `main` triggers GitHub Actions
2. Tests run with PostgreSQL 11 service container
3. Security checks: bundler-audit + Brakeman
4. Cloud Build creates Docker image
5. Image pushed to Google Container Registry
6. Database migrations run via Cloud SQL Proxy
7. Cloud Run service updated

### Production Infrastructure
- **Platform:** Google Cloud Run (europe-west1)
- **Database:** Cloud SQL PostgreSQL (instance: budgetlab)
- **Storage:** Google Cloud Storage (bucket: opera-bucket)
- **Secrets:** Google Secret Manager (RAILS_MASTER_KEY)

## Useful Commands

```bash
# Rails console in production
bin/rails console -e production

# Check routes
bin/rails routes | grep opera

# Generate model
bin/rails generate model ModelName field:type

# Database console
bin/rails dbconsole
```
