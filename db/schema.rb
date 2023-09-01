# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_09_01_144317) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "ministeres", force: :cascade do |t|
    t.string "nom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "missions", force: :cascade do |t|
    t.string "nom"
    t.bigint "programme_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["programme_id"], name: "index_missions_on_programme_id"
  end

  create_table "modifications", force: :cascade do |t|
    t.bigint "organisme_id", null: false
    t.bigint "user_id", null: false
    t.string "champ"
    t.string "statut"
    t.string "ancienne_valeur"
    t.string "nouvelle_valeur"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "commentaire"
    t.string "nom"
    t.index ["organisme_id"], name: "index_modifications_on_organisme_id"
    t.index ["user_id"], name: "index_modifications_on_user_id"
  end

  create_table "operateur_programmes", force: :cascade do |t|
    t.bigint "operateur_id", null: false
    t.bigint "programme_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["operateur_id"], name: "index_operateur_programmes_on_operateur_id"
    t.index ["programme_id"], name: "index_operateur_programmes_on_programme_id"
  end

  create_table "operateurs", force: :cascade do |t|
    t.bigint "organisme_id", null: false
    t.boolean "operateur_n"
    t.boolean "operateur_n1"
    t.boolean "operateur_n2"
    t.boolean "presence_categorie"
    t.string "nom_categorie"
    t.bigint "mission_id", null: false
    t.bigint "programme_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "operateur_nf"
    t.index ["mission_id"], name: "index_operateurs_on_mission_id"
    t.index ["organisme_id"], name: "index_operateurs_on_organisme_id"
    t.index ["programme_id"], name: "index_operateurs_on_programme_id"
  end

  create_table "organisme_ministeres", force: :cascade do |t|
    t.bigint "organisme_id", null: false
    t.bigint "ministere_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ministere_id"], name: "index_organisme_ministeres_on_ministere_id"
    t.index ["organisme_id"], name: "index_organisme_ministeres_on_organisme_id"
  end

  create_table "organisme_rattachements", force: :cascade do |t|
    t.bigint "organisme_id", null: false
    t.bigint "organisme_destination_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisme_destination_id"], name: "index_organisme_rattachements_on_organisme_destination_id"
    t.index ["organisme_id"], name: "index_organisme_rattachements_on_organisme_id"
  end

  create_table "organismes", force: :cascade do |t|
    t.string "etat"
    t.string "siren"
    t.string "acronyme"
    t.string "nom"
    t.string "famille"
    t.string "nature"
    t.date "date_creation"
    t.date "date_dissolution"
    t.date "date_previsionnelle_dissolution"
    t.string "effet_dissolution"
    t.bigint "bureau_id"
    t.string "texte_institutif"
    t.string "commentaire"
    t.string "statut"
    t.boolean "gbcp_1"
    t.boolean "agent_comptable_present"
    t.string "degre_gbcp"
    t.boolean "gbcp_3"
    t.string "comptabilite_budgetaire"
    t.boolean "presence_controle"
    t.string "nature_controle"
    t.string "texte_soumission_controle"
    t.string "autorite_controle"
    t.bigint "controleur_id", null: false
    t.string "texte_reglementaire_controle"
    t.string "arrete_controle"
    t.boolean "document_controle_present"
    t.string "document_controle_lien"
    t.date "document_controle_date"
    t.string "arrete_nomination"
    t.boolean "tutelle_financiere"
    t.boolean "delegation_approbation"
    t.string "autorite_approbation"
    t.boolean "admin_db_present"
    t.string "admin_db_fonction"
    t.boolean "admin_preca"
    t.boolean "controleur_preca"
    t.boolean "controleur_ca"
    t.boolean "comite_audit"
    t.boolean "apu"
    t.boolean "ciassp_n"
    t.boolean "ciassp_n1"
    t.boolean "odac_n"
    t.boolean "odac_n1"
    t.boolean "odal_n"
    t.boolean "odal_n1"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ministere_id"
    t.string "arrete_interdiction_odac"
    t.index ["bureau_id"], name: "index_organismes_on_bureau_id"
    t.index ["controleur_id"], name: "index_organismes_on_controleur_id"
    t.index ["ministere_id"], name: "index_organismes_on_ministere_id"
  end

  create_table "programmes", force: :cascade do |t|
    t.integer "numero"
    t.string "nom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "statut"
    t.string "nom"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "missions", "programmes"
  add_foreign_key "modifications", "organismes"
  add_foreign_key "modifications", "users"
  add_foreign_key "operateur_programmes", "operateurs"
  add_foreign_key "operateur_programmes", "programmes"
  add_foreign_key "operateurs", "missions"
  add_foreign_key "operateurs", "organismes"
  add_foreign_key "operateurs", "programmes"
  add_foreign_key "organisme_ministeres", "ministeres"
  add_foreign_key "organisme_ministeres", "organismes"
  add_foreign_key "organisme_rattachements", "organismes"
  add_foreign_key "organisme_rattachements", "organismes", column: "organisme_destination_id"
  add_foreign_key "organismes", "ministeres"
  add_foreign_key "organismes", "users", column: "bureau_id"
  add_foreign_key "organismes", "users", column: "controleur_id"
end
