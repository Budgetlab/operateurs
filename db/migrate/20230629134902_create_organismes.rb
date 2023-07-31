class CreateOrganismes < ActiveRecord::Migration[7.0]
  def change
    create_table :organismes do |t|
      t.string :etat
      t.integer :siren
      t.string :acronyme
      t.string :nom
      t.string :famille
      t.string :nature
      t.date :date_creation
      t.date :date_dissolution
      t.date :date_previsionnelle_dissolution
      t.string :effet_dissolution
      t.references :bureau, null: false, foreign_key: { to_table: :users }
      t.string :texte_institutif
      t.string :commentaire
      t.string :statut
      t.boolean :gbcp_1
      t.boolean :agent_comptable_present
      t.string :degre_gbcp
      t.boolean :gbcp_3
      t.string :comptabilite_budgetaire
      t.boolean :presence_controle
      t.string :nature_controle
      t.string :texte_soumission_controle
      t.string :autorite_controle
      t.references :controleur, null: false, foreign_key: { to_table: :users }
      t.string :texte_reglementaire_controle
      t.string :arrete_controle
      t.boolean :document_controle_present
      t.string :document_controle_lien
      t.date :document_controle_date
      t.string :arrete_nomination
      t.boolean :tutelle_financiere
      t.boolean :delegation_approbation
      t.string :autorite_approbation
      t.references :ministere, null: false, foreign_key: true
      t.boolean :admin_db_present
      t.string :admin_db_fonction
      t.boolean :admin_preca
      t.boolean :controleur_preca
      t.boolean :controleur_ca
      t.boolean :comite_audit
      t.boolean :apu
      t.boolean :ciassp_n
      t.boolean :ciassp_n1
      t.boolean :odac_n
      t.boolean :odac_n1
      t.boolean :odal_n
      t.boolean :odal_n1

      t.timestamps
    end
  end
end
