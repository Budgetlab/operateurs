# frozen_string_literal: true

# Model Organisme
class Organisme < ApplicationRecord
  belongs_to :bureau, class_name: 'User'
  belongs_to :controleur, class_name: 'User'
  belongs_to :ministere
  has_many :organisme_rattachements, dependent: :destroy
  has_many :organisme_destinations, through: :organisme_rattachements
  has_many :organisme_ministeres, dependent: :destroy
  has_one :operateur
  has_many :modifications, dependent: :destroy
  def self.import(file)
    data = Roo::Spreadsheet.open(file.path)
    headers = data.row(1) # get header row
    data.each_with_index do |row, idx|
      next if idx == 0 # skip header

      row_data = Hash[[headers, row].transpose]
      organisme = Organisme.new
      column_names = %w[nom etat siren acronyme famille nature date_creation date_dissolution
                        date_previsionnelle_dissolution effet_dissolution texte_institutif commentaire gbcp_1
                        agent_comptable_present degre_gbcp gbcp_3 comptabilite_budgetaire presence_controle
                        nature_controle texte_soumission_controle autorite_controle texte_reglementaire_controle
                        arrete_controle document_controle_present document_controle_lien document_controle_date
                        arrete_nomination tutelle_financiere delegation_approbation autorite_approbation
                        admin_db_present admin_db_fonction admin_preca controleur_preca controleur_ca comite_audit
                        apu ciassp_n ciassp_n1 odac_n odac_n1 odal_n odal_n1]
      organisme.attributes = row_data.slice(*column_names) # Récupérer uniquement les colonnes existantes dans la table
      organisme.statut = 'valide'
      organisme.ministere = Ministere.find_by(nom: row_data['Ministere'].to_s)
      organisme.bureau_id = User.find_by(nom: row_data['Bureau'].to_s)&.id
      organisme.controleur_id = User.find_by(nom: row_data['Controleur'].to_s)&.id
      organisme.save
    end
  end
end
