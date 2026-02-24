# Source Tree Analysis — OPERA

> Generated: 2026-02-24 | Scan level: deep

## Annotated Directory Tree

```
operateurs/                          # Rails 8.1 application root
├── app/                             # ★ Main application code
│   ├── admin/                       # ActiveAdmin resource definitions (16 files)
│   │   ├── admin_users.rb           #   Admin user CRUD
│   │   ├── chiffres.rb              #   Budget data admin
│   │   ├── dashboard.rb             #   Admin dashboard
│   │   ├── enquete_questions.rb     #   Survey questions admin
│   │   ├── enquete_reponses.rb      #   Survey responses admin
│   │   ├── enquetes.rb              #   Survey years admin
│   │   ├── ministeres.rb            #   Ministries admin
│   │   ├── missions.rb              #   Missions admin
│   │   ├── modifications.rb         #   Change tracking admin
│   │   ├── operateur_programmes.rb  #   Operator-program links admin
│   │   ├── operateurs.rb            #   Operators admin
│   │   ├── organisme_ministeres.rb  #   Organism-ministry links admin
│   │   ├── organisme_rattachements.rb # Organism attachments admin
│   │   ├── organismes.rb            #   Organisms admin
│   │   ├── programmes.rb            #   Programs admin
│   │   └── users.rb                 #   Users admin
│   │
│   ├── assets/                      # Static assets
│   │   ├── config/
│   │   │   └── manifest.js          #   Sprockets manifest
│   │   ├── fonts/                   #   Marianne & Spectral (DSFR) — 22 font files
│   │   ├── images/
│   │   │   └── artwork/             #   DSFR pictograms & backgrounds
│   │   │       ├── background/
│   │   │       ├── favicon/
│   │   │       └── pictograms/      #   buildings, digital, document, environment,
│   │   │                            #   health, institutions, leisure, map, system
│   │   ├── javascripts/
│   │   │   └── active_admin.js      #   ActiveAdmin JS assets
│   │   └── stylesheets/
│   │       ├── active_admin.scss    #   ActiveAdmin custom styles
│   │       ├── application.scss     #   ★ Main app styles (375 lines) — DSFR overrides
│   │       ├── dsfr.scss            #   DSFR full implementation (35,909 lines)
│   │       ├── pdf.scss             #   PDF-specific styles with Marianne fonts
│   │       └── utility.scss         #   DSFR v1.12.1 utility classes
│   │
│   ├── channels/                    # ActionCable (base classes, unused)
│   │   └── application_cable/
│   │       ├── channel.rb
│   │       └── connection.rb
│   │
│   ├── controllers/                 # ★ Request handling (15 controllers + 1 concern)
│   │   ├── application_controller.rb    # ★ Base: auth, global vars, famille filtering
│   │   ├── chiffres_controller.rb       # ★ Budget CRUD, exports, phases (392 lines)
│   │   ├── control_documents_controller.rb # Document CRUD with file upload
│   │   ├── enquete_questions_controller.rb # Survey questions listing
│   │   ├── enquete_reponses_controller.rb  # Survey results, import, export
│   │   ├── errors_controller.rb         # Error pages (404, 500, 503)
│   │   ├── ministeres_controller.rb     # Ministry CRUD + import
│   │   ├── missions_controller.rb       # Mission/program import
│   │   ├── modifications_controller.rb  # Change tracking workflow
│   │   ├── objectifs_contrats_controller.rb # Contract objectives CRUD
│   │   ├── operateurs_controller.rb     # Operator CRUD + import
│   │   ├── organismes_controller.rb     # ★ Organism CRUD, search, import (389 lines)
│   │   ├── pages_controller.rb          # Dashboard + static pages
│   │   ├── sessions_controller.rb       # Custom Devise login (by role + name)
│   │   ├── users_controller.rb          # User import + AJAX helpers
│   │   └── concerns/
│   │       └── authentication.rb        # redirect_unless_controleur
│   │
│   ├── helpers/                     # View helpers
│   │   ├── application_helper.rb    # ★ 20+ helpers: formatting, pagination, badges
│   │   ├── chiffres_helper.rb       #   (empty)
│   │   ├── enquete_reponses_helper.rb # (empty)
│   │   ├── operateurs_helper.rb     #   (empty)
│   │   ├── organismes_helper.rb     #   (empty)
│   │   └── pages_helper.rb          #   (empty)
│   │
│   ├── javascript/                  # ★ Frontend JavaScript
│   │   ├── application.js           #   Entry point: Turbo + Stimulus boot
│   │   ├── controllers/             #   Stimulus controllers (11 files)
│   │   │   ├── application.js       #   Stimulus base setup
│   │   │   ├── filter_controller.js #   Form filter submission
│   │   │   ├── flatpickr_controller.js # Date picker (FR locale)
│   │   │   ├── form_controller.js   #   ★ Complex form validation (200+ lines)
│   │   │   ├── highcharts_controller.js # ★ Financial charts (51KB)
│   │   │   ├── index.js             #   Controller auto-registration
│   │   │   ├── pdf_export_controller.js # Client-side PDF export
│   │   │   ├── request_controller.js #  Tag-based filtering
│   │   │   ├── search_controller.js #   Organism autocomplete
│   │   │   ├── session_controller.js #  Login form management
│   │   │   ├── tab_controller.js    #   DSFR tab navigation
│   │   │   └── toggle_controller.js #   Collapsible sections
│   │   └── custom/
│   │       ├── dsfr.module.min.js   #   DSFR module version
│   │       └── dsfr.nomodule.min.js #   DSFR fallback version
│   │
│   ├── jobs/
│   │   ├── application_job.rb       #   Base job class
│   │   └── url_to_pdf_job.rb        #   PDF generation job (Ferrum)
│   │
│   ├── mailers/
│   │   └── application_mailer.rb    #   Base mailer class
│   │
│   ├── models/                      # ★ Domain models (18 files)
│   │   ├── application_record.rb    #   Base model class
│   │   ├── admin_user.rb            #   Admin authentication (Devise)
│   │   ├── chiffre.rb               #   ★ Budget data + financial calculations (382 lines)
│   │   ├── control_document.rb      #   Document with file attachment
│   │   ├── enquete.rb               #   Survey year
│   │   ├── enquete_question.rb      #   Survey question
│   │   ├── enquete_reponse.rb       #   Survey response (JSONB storage)
│   │   ├── ministere.rb             #   Ministry + import
│   │   ├── mission.rb               #   Budget mission + import
│   │   ├── modification.rb          #   Change tracking record
│   │   ├── objectifs_contrat.rb     #   Contract objective with attachment
│   │   ├── operateur.rb             #   Operator link + import
│   │   ├── operateur_programme.rb   #   Operator-program join
│   │   ├── organisme.rb             #   ★ Core organism + import (159 lines)
│   │   ├── organisme_ministere.rb   #   Organism-ministry join
│   │   ├── organisme_rattachement.rb #  Organism self-referential join
│   │   ├── programme.rb             #   Budget program
│   │   └── user.rb                  #   User authentication + roles
│   │
│   └── views/                       # ★ ERB templates (~120 files)
│       ├── chiffres/                #   29 templates (budget forms, tabs, badges)
│       ├── control_documents/       #   5 templates
│       ├── devise/                  #   14+ auth templates
│       ├── enquete_questions/       #   1 template
│       ├── enquete_reponses/        #   3 templates
│       ├── errors/                  #   3 error pages
│       ├── layouts/                 #   5 layouts
│       ├── ministeres/              #   2 templates
│       ├── missions/                #   1 template
│       ├── modifications/           #   6 templates
│       ├── objectifs_contrats/      #   5 templates
│       ├── operateurs/              #   4 templates
│       ├── organismes/              #   20 templates
│       ├── pages/                   #   5 templates
│       └── users/                   #   1 template
│
├── bin/                             # Executable scripts
│   ├── bundle                       #   Bundler wrapper
│   ├── importmap                    #   Import map management
│   ├── rails                        #   ★ Rails CLI entry point
│   ├── rake                         #   Rake task runner
│   ├── setup                        #   Development setup script
│   ├── dev                          #   Dev server launcher
│   ├── docker-entrypoint            #   Docker entry script
│   ├── jobs                         #   Job runner
│   └── thrust                       #   Thruster proxy
│
├── config/                          # ★ Application configuration
│   ├── environments/                #   dev.rb, test.rb, production.rb
│   ├── initializers/                #   11 initializer files
│   │   ├── active_admin.rb          #   Admin panel setup
│   │   ├── assets.rb                #   Asset pipeline
│   │   ├── content_security_policy.rb # CSP headers
│   │   ├── devise.rb               #   Authentication config
│   │   ├── filter_parameter_logging.rb # Param filtering
│   │   ├── inflections.rb           #   Rails inflection rules
│   │   ├── mime_types.rb            #   MIME type registration
│   │   ├── pagy.rb                  #   Pagination setup
│   │   ├── permissions_policy.rb    #   Permissions policy
│   │   ├── ransack.rb              #   Search configuration
│   │   └── wicked_pdf.rb           #   PDF generation setup
│   ├── locales/                     #   i18n: fr.yml, en.yml, devise.en.yml
│   ├── application.rb              #   ★ Rails app config (locale: fr)
│   ├── database.yml                #   PostgreSQL (Cloud SQL in prod)
│   ├── importmap.rb                #   JS dependency map
│   ├── puma.rb                     #   Web server config
│   ├── routes.rb                   #   ★ All routes under /opera scope
│   └── storage.yml                 #   GCS in production
│
├── db/                              # Database
│   ├── migrate/                     #   40 migration files (2023–2026)
│   ├── schema.rb                    #   ★ Current schema (16 tables)
│   └── seeds.rb                     #   Initial data seeding
│
├── lib/                             # Custom library code
│   ├── assets/                      #   (empty)
│   └── tasks/                       #   (empty)
│
├── public/                          # Static files served directly
│   ├── 400.html, 404.html, 422.html, 500.html  # Error pages
│   ├── 406-unsupported-browser.html # Browser compatibility
│   ├── Charte_utilisation_OPERA.docx # Usage charter document
│   ├── favicon.ico, icon.png, icon.svg # Favicons
│   └── robots.txt                   # Search engine directives
│
├── storage/                         # Active Storage local files (dev)
├── test/                            # Test suite
│   ├── fixtures/                    #   YAML test data
│   ├── models/                      #   18+ model test files
│   ├── system/                      #   System tests (Capybara)
│   └── application_system_test_case.rb
│
├── .github/workflows/
│   └── rubyonrails.yml             # CI: tests + security audit
├── Dockerfile                       # Docker: Ruby 3.4 + Node 18 + Chrome
├── Gemfile                          # ★ Ruby dependencies
├── Procfile                         # Puma server config
├── cloudbuild.yaml                  # GCP Cloud Build pipeline
└── config.ru                        # Rack entry point
```

## Critical Folders

| Folder | Purpose | Key Files |
|--------|---------|-----------|
| `app/controllers/` | Request handling | organismes_controller.rb (389 LOC), chiffres_controller.rb (392 LOC) |
| `app/models/` | Domain logic | chiffre.rb (382 LOC), organisme.rb (159 LOC) |
| `app/views/` | Templates | ~120 ERB files across 15 directories |
| `app/javascript/controllers/` | Frontend logic | highcharts_controller.js (51KB), form_controller.js |
| `config/` | Configuration | routes.rb, database.yml, initializers/ |
| `db/` | Schema & migrations | schema.rb (16 tables), 40 migrations |

## Entry Points

| Entry Point | File | Description |
|-------------|------|-------------|
| Web request | `config.ru` → `Rails.application` | Rack entry point |
| Routes | `config/routes.rb` | All under `/opera` scope |
| Application boot | `config/application.rb` | Rails module: Operateurs |
| Docker | `bin/rails server -b 0.0.0.0 -p 8080` | Container entry |
| Admin panel | `/opera/admin/` | ActiveAdmin interface |
