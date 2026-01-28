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

ActiveRecord::Schema[8.1].define(version: 2026_01_28_144129) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "unaccent"

  create_table "active_admin_comments", force: :cascade do |t|
    t.bigint "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at", null: false
    t.string "namespace"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "chiffres", force: :cascade do |t|
    t.float "capacite_autofinancement"
    t.float "charges_fonctionnement"
    t.float "charges_intervention"
    t.float "charges_non_decaissables"
    t.string "commentaire"
    t.string "commentaire_annexe"
    t.boolean "comptabilite_budgetaire"
    t.datetime "created_at", null: false
    t.float "credits_ae_fonctionnement"
    t.float "credits_ae_intervention"
    t.float "credits_ae_investissement"
    t.float "credits_ae_total"
    t.float "credits_cp_fonctionnement"
    t.float "credits_cp_intervention"
    t.float "credits_cp_investissement"
    t.float "credits_cp_operations"
    t.float "credits_cp_recettes_flechees"
    t.float "credits_cp_total"
    t.float "credits_financements_etat_autres"
    t.float "credits_financements_etat_fleches"
    t.float "credits_financements_publics_autres"
    t.float "credits_financements_publics_fleches"
    t.float "credits_fiscalite_affectee"
    t.float "credits_recettes_propres_flechees"
    t.float "credits_recettes_propres_globalisees"
    t.float "credits_restes_a_payer"
    t.float "credits_subvention_investissement_flechee"
    t.float "credits_subvention_investissement_globalisee"
    t.float "credits_subvention_sp"
    t.float "decaissements_autres"
    t.float "decaissements_emprunts"
    t.float "decaissements_operations"
    t.float "emplois_autre_entite"
    t.float "emplois_charges_personnel"
    t.float "emplois_contractuels"
    t.float "emplois_contractuels_montant"
    t.float "emplois_cout_investissements"
    t.float "emplois_cout_total"
    t.float "emplois_depenses_personnel"
    t.float "emplois_hors_plafond"
    t.float "emplois_non_remuneres"
    t.float "emplois_plafond"
    t.float "emplois_plafond_prenotifie"
    t.float "emplois_plafond_rappel"
    t.float "emplois_schema"
    t.float "emplois_schema_prenotifie"
    t.float "emplois_titulaires"
    t.float "emplois_titulaires_montant"
    t.float "emplois_total"
    t.float "encaissements_autres"
    t.float "encaissements_emprunts"
    t.float "encaissements_operations"
    t.integer "exercice_budgetaire"
    t.float "fonds_roulement_besoin_final"
    t.float "fonds_roulement_final"
    t.float "fonds_roulement_variation"
    t.boolean "operateur"
    t.bigint "organisme_id", null: false
    t.string "phase"
    t.float "produits_autres"
    t.float "produits_fiscalite_affectee"
    t.float "produits_non_encaissables"
    t.float "produits_subventions_autres"
    t.float "produits_subventions_etat"
    t.float "ressources_autres"
    t.float "ressources_financement_etat"
    t.float "ressources_total"
    t.string "risque_insolvabilite"
    t.string "statut"
    t.float "tresorerie_finale"
    t.float "tresorerie_finale_flechee"
    t.float "tresorerie_finale_non_flechee"
    t.float "tresorerie_max"
    t.date "tresorerie_max_date"
    t.float "tresorerie_min"
    t.date "tresorerie_min_date"
    t.float "tresorerie_variation"
    t.float "tresorerie_variation_flechee"
    t.float "tresorerie_variation_non_flechee"
    t.string "type_budget"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organisme_id"], name: "index_chiffres_on_organisme_id"
    t.index ["user_id"], name: "index_chiffres_on_user_id"
  end

  create_table "control_documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "organisme_id", null: false
    t.date "signature_date"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organisme_id"], name: "index_control_documents_on_organisme_id"
    t.index ["user_id"], name: "index_control_documents_on_user_id"
  end

  create_table "enquete_questions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "enquete_id", null: false
    t.text "nom"
    t.integer "numero"
    t.datetime "updated_at", null: false
    t.index ["enquete_id"], name: "index_enquete_questions_on_enquete_id"
  end

  create_table "enquete_reponses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "enquete_id", null: false
    t.bigint "organisme_id", null: false
    t.jsonb "reponses", default: {}
    t.datetime "updated_at", null: false
    t.index ["enquete_id"], name: "index_enquete_reponses_on_enquete_id"
    t.index ["organisme_id"], name: "index_enquete_reponses_on_organisme_id"
  end

  create_table "enquetes", force: :cascade do |t|
    t.integer "annee", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ministeres", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nom"
    t.datetime "updated_at", null: false
  end

  create_table "missions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nom"
    t.bigint "programme_id", null: false
    t.string "statut", default: "actif"
    t.datetime "updated_at", null: false
    t.index ["programme_id"], name: "index_missions_on_programme_id"
  end

  create_table "modifications", force: :cascade do |t|
    t.string "ancienne_valeur"
    t.string "champ"
    t.string "commentaire"
    t.datetime "created_at", null: false
    t.string "nom"
    t.string "nouvelle_valeur"
    t.bigint "organisme_id", null: false
    t.string "statut"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organisme_id"], name: "index_modifications_on_organisme_id"
    t.index ["user_id"], name: "index_modifications_on_user_id"
  end

  create_table "objectifs_contrats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "debut"
    t.integer "fin"
    t.string "nom"
    t.bigint "organisme_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organisme_id"], name: "index_objectifs_contrats_on_organisme_id"
    t.index ["user_id"], name: "index_objectifs_contrats_on_user_id"
  end

  create_table "operateur_programmes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "operateur_id", null: false
    t.bigint "programme_id", null: false
    t.datetime "updated_at", null: false
    t.index ["operateur_id"], name: "index_operateur_programmes_on_operateur_id"
    t.index ["programme_id"], name: "index_operateur_programmes_on_programme_id"
  end

  create_table "operateurs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "mission_id", null: false
    t.string "nom_categorie"
    t.boolean "operateur_n"
    t.boolean "operateur_n1"
    t.boolean "operateur_n2"
    t.boolean "operateur_nf"
    t.bigint "organisme_id", null: false
    t.boolean "presence_categorie"
    t.bigint "programme_id", null: false
    t.datetime "updated_at", null: false
    t.index ["mission_id"], name: "index_operateurs_on_mission_id"
    t.index ["organisme_id"], name: "index_operateurs_on_organisme_id"
    t.index ["programme_id"], name: "index_operateurs_on_programme_id"
  end

  create_table "organisme_ministeres", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "ministere_id", null: false
    t.bigint "organisme_id", null: false
    t.datetime "updated_at", null: false
    t.index ["ministere_id"], name: "index_organisme_ministeres_on_ministere_id"
    t.index ["organisme_id"], name: "index_organisme_ministeres_on_organisme_id"
  end

  create_table "organisme_rattachements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "organisme_destination_id", null: false
    t.bigint "organisme_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organisme_destination_id"], name: "index_organisme_rattachements_on_organisme_destination_id"
    t.index ["organisme_id"], name: "index_organisme_rattachements_on_organisme_id"
  end

  create_table "organismes", force: :cascade do |t|
    t.string "acronyme"
    t.string "admin_db_fonction"
    t.boolean "admin_db_present"
    t.boolean "admin_preca"
    t.boolean "agent_comptable_present"
    t.boolean "apu"
    t.string "arrete_controle"
    t.string "arrete_interdiction_odac"
    t.string "arrete_nomination"
    t.string "autorite_approbation"
    t.string "autorite_controle"
    t.bigint "bureau_id"
    t.boolean "ciassp_n"
    t.boolean "ciassp_n1"
    t.boolean "comite_audit"
    t.string "commentaire"
    t.string "comptabilite_budgetaire"
    t.boolean "controleur_ca"
    t.bigint "controleur_id", null: false
    t.boolean "controleur_preca"
    t.datetime "created_at", null: false
    t.date "date_creation"
    t.date "date_dissolution"
    t.date "date_previsionnelle_dissolution"
    t.string "degre_gbcp"
    t.boolean "delegation_approbation"
    t.boolean "document_controle_present"
    t.string "effet_dissolution"
    t.string "etat"
    t.string "famille"
    t.boolean "gbcp_1"
    t.boolean "gbcp_3"
    t.bigint "ministere_id"
    t.string "nature"
    t.string "nature_controle"
    t.string "nom"
    t.boolean "odac_n"
    t.boolean "odac_n1"
    t.boolean "odal_n"
    t.boolean "odal_n1"
    t.boolean "presence_controle"
    t.string "siren"
    t.string "statut"
    t.float "taux_cadrage_n"
    t.float "taux_cadrage_n1"
    t.string "texte_institutif"
    t.string "texte_reglementaire_controle"
    t.string "texte_soumission_controle"
    t.boolean "tutelle_financiere"
    t.datetime "updated_at", null: false
    t.index ["bureau_id"], name: "index_organismes_on_bureau_id"
    t.index ["controleur_id"], name: "index_organismes_on_controleur_id"
    t.index ["ministere_id"], name: "index_organismes_on_ministere_id"
  end

  create_table "programmes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nom"
    t.integer "numero"
    t.string "statut", default: "actif"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "nom"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "statut"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chiffres", "organismes"
  add_foreign_key "chiffres", "users"
  add_foreign_key "control_documents", "organismes"
  add_foreign_key "control_documents", "users"
  add_foreign_key "enquete_questions", "enquetes"
  add_foreign_key "enquete_reponses", "enquetes"
  add_foreign_key "enquete_reponses", "organismes"
  add_foreign_key "missions", "programmes"
  add_foreign_key "modifications", "organismes"
  add_foreign_key "modifications", "users"
  add_foreign_key "objectifs_contrats", "organismes"
  add_foreign_key "objectifs_contrats", "users"
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
