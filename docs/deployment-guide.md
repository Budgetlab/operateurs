# Deployment Guide — OPERA

> Generated: 2026-02-24 | Scan level: deep

## Infrastructure

| Component | Service | Details |
|-----------|---------|---------|
| **Compute** | Google Cloud Run | Region: europe-west1, Service: opera-test |
| **Database** | Google Cloud SQL | Instance: budgetlab, PostgreSQL |
| **Storage** | Google Cloud Storage | Bucket: opera-bucket |
| **Registry** | Google Container Registry | gcr.io/apps-354210/opera-test |
| **Secrets** | Google Secret Manager | Secret: opera-secret (RAILS_MASTER_KEY) |
| **CI/CD** | GitHub Actions + Cloud Build | Tests → Build → Deploy |

## Deployment Pipeline

```
GitHub (main)
    │
    ▼
GitHub Actions ─────────────────────────────────
    ├── Test job
    │   ├── PostgreSQL 11 service
    │   ├── Ruby 3.4 setup
    │   ├── bundle install (cached)
    │   ├── db:schema:load
    │   └── bin/rake (full test suite)
    │
    └── Lint job
        ├── bundle audit --update
        └── brakeman -q -w2
    │
    ▼ (on success)
Google Cloud Build ─────────────────────────────
    ├── Step 1: docker build
    │   ├── Base: ruby:3.4
    │   ├── Node.js 18.x + Yarn
    │   ├── Google Chrome (for PDF)
    │   ├── bundle install
    │   ├── assets:precompile
    │   └── ARG MASTER_KEY from Secret Manager
    │
    ├── Step 2: docker push → GCR
    │
    └── Step 3: db:migrate
        └── Via exec-wrapper + Cloud SQL Proxy
    │
    ▼
Cloud Run (europe-west1)
    ├── Port: 8080
    ├── Health check: /up
    └── Auto-scaling enabled
```

## Docker Configuration

### Dockerfile Summary
- **Base image:** `ruby:3.4`
- **System deps:** Node.js 18.x, Yarn, Google Chrome stable
- **Ruby deps:** Bundler → `bundle install`
- **Assets:** `rake assets:precompile` (requires RAILS_MASTER_KEY)
- **Exposed port:** 8080
- **Entry command:** `bin/rails server -b 0.0.0.0 -p 8080`
- **Platform locks:** ruby, x86_64-linux

### Build Command
```bash
docker build \
  --build-arg MASTER_KEY=<rails-master-key> \
  -t gcr.io/apps-354210/opera-test .
```

## Environment Variables

### Required in Production

| Variable | Source | Purpose |
|----------|--------|---------|
| `RAILS_MASTER_KEY` | Secret Manager | Decrypt credentials.yml.enc |
| `RAILS_ENV` | Dockerfile | Set to `production` |
| `RAILS_SERVE_STATIC_FILES` | Dockerfile | Enable static file serving |
| `RAILS_LOG_TO_STDOUT` | Dockerfile | Route logs to Cloud Logging |
| `PRODUCTION_DB_NAME` | .env / Cloud Run | Database name |
| `PRODUCTION_DB_USERNAME` | .env / Cloud Run | Database user |
| `CLOUD_SQL_CONNECTION_NAME` | .env / Cloud Run | Cloud SQL instance |
| `GOOGLE_PROJECT_ID` | .env / Cloud Run | GCP project ID |
| `STORAGE_BUCKET_NAME` | .env / Cloud Run | GCS bucket name |

### Encrypted Credentials (via RAILS_MASTER_KEY)

| Key Path | Purpose |
|----------|---------|
| `gcp.db_password` | PostgreSQL password |
| `gcp.private_key_id` | GCS service account key ID |
| `gcp.private_key` | GCS service account private key |

## Cloud Build Configuration (cloudbuild.yaml)

### Step 1 — Build Docker Image
```yaml
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '--build-arg', 'MASTER_KEY=$$RAILS_KEY', '-t', 'gcr.io/$PROJECT_ID/opera-test', '.']
  secretEnv: ['RAILS_KEY']
```

### Step 2 — Push to Registry
```yaml
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/$PROJECT_ID/opera-test']
```

### Step 3 — Database Migration
```yaml
- name: 'gcr.io/google-appengine/exec-wrapper'
  args: ['-i', 'gcr.io/$PROJECT_ID/opera-test',
         '-s', '$PROJECT_ID:europe-west1:budgetlab',
         '-e', 'RAILS_MASTER_KEY=$$RAILS_KEY',
         '--', 'bundle', 'exec', 'rails', 'db:migrate']
  secretEnv: ['RAILS_KEY']
```

### Secrets
```yaml
availableSecrets:
  secretManager:
    - versionName: projects/$PROJECT_ID/secrets/opera-secret/versions/latest
      env: 'RAILS_KEY'
```

## GitHub Actions CI (.github/workflows/rubyonrails.yml)

### Test Job
- **Trigger:** Push or PR to `main`
- **Services:** PostgreSQL 11 (alpine)
- **Ruby:** 3.4 via ruby/setup-ruby@v1
- **Steps:** checkout → setup ruby → db:schema:load → bin/rake

### Lint Job
- **bundler-audit:** Checks gem dependencies for known vulnerabilities
- **Brakeman:** Static security analysis for Rails-specific issues

## Database Management

### Connection (Production)
```yaml
adapter: postgresql
database: opera-test
username: postgres
password: Rails.application.credentials.gcp[:db_password]
host: "/cloudsql/apps-354210:europe-west1:budgetlab"
```

Connection uses **Unix socket** via Cloud SQL Proxy (no TCP exposure).

### Migrations
Migrations run automatically during Cloud Build (Step 3). For manual execution:
```bash
# Via Cloud SQL Proxy
bundle exec rails db:migrate

# Check migration status
bundle exec rails db:migrate:status
```

## Storage (Active Storage)

### Production Configuration
```yaml
google:
  service: GCS
  project: apps-354210
  bucket: opera-bucket
  credentials:
    type: service_account
    project_id: apps-354210
    client_email: operaservice@apps-354210.iam.gserviceaccount.com
```

Files are stored in Google Cloud Storage and served via Active Storage URLs.

## Server Configuration (Puma)

```ruby
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count
port ENV.fetch("PORT", 3000)  # 8080 in Docker
plugin :tmp_restart
```

## Health Check

Rails provides a built-in health endpoint at `/up` (excluded from logging in production).

## Monitoring

- **Logs:** Routed to STDOUT → captured by Cloud Run / Cloud Logging
- **Log tags:** `request_id` for request tracing
- **Log level:** Configurable via `RAILS_LOG_LEVEL` (default: info)
