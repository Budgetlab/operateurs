# frozen_string_literal: true

# Model Organisme
class Organisme < ApplicationRecord
  belongs_to :bureau, class_name: 'User', optional: true
  belongs_to :controleur, class_name: 'User'
  belongs_to :ministere, optional: true
  has_many :organisme_rattachements, dependent: :destroy
  has_many :organisme_destinations, through: :organisme_rattachements
  has_many :organisme_ministeres, dependent: :destroy
  has_one :operateur, dependent: :destroy
  has_many :modifications, dependent: :destroy
  has_many :chiffres, dependent: :destroy
  has_many :control_documents, dependent: :destroy

  def self.import(file)
    data = Roo::Spreadsheet.open(file.path)
    headers = data.row(1) # get header row
    data.each_with_index do |row, idx|
      next if idx == 0 # skip header

      row_data = Hash[[headers, row].transpose]
      next if row_data['nom'].blank?

      organisme = Organisme.new
      column_names = %w[nom etat siren acronyme famille nature date_creation date_dissolution
                        date_previsionnelle_dissolution effet_dissolution texte_institutif commentaire gbcp_1
                        agent_comptable_present degre_gbcp gbcp_3 comptabilite_budgetaire presence_controle
                        nature_controle texte_soumission_controle autorite_controle texte_reglementaire_controle
                        arrete_controle document_controle_present document_controle_date
                        arrete_nomination tutelle_financiere delegation_approbation autorite_approbation
                        admin_db_present admin_db_fonction admin_preca controleur_preca controleur_ca comite_audit
                        apu ciassp_n ciassp_n1 odac_n odac_n1 odal_n odal_n1 arrete_interdiction_odac]
      column_names.each do |column_name|
        row_data[column_name] = convert_to_boolean(row_data[column_name]) if column_name != 'comptabilite_budgetaire'
      end
      organisme.attributes = row_data.slice(*column_names) # Récupérer uniquement les colonnes existantes dans la table
      organisme.statut = 'valide'
      organisme.ministere_id = Ministere.find_by(nom: row_data['Ministere'].to_s)&.id
      organisme.bureau_id = User.find_by(nom: row_data['Bureau'].to_s)&.id
      user = User.find_by(nom: row_data['Controleur'].to_s) || User.find_by(nom: '2B2O')
      organisme.controleur_id = user.id
      organisme.nom[0] = organisme.nom[0].capitalize if organisme.nom[0] == organisme.nom[0].downcase
      organisme.texte_institutif = nil if organisme.texte_institutif == ' '
      organisme.save
      if organisme.save
      ministere_array = row_data['Cotutelle'].to_s.split(' / ') || []
      ministere_array.each do |ministere|
        ministere_id = Ministere.find_by(nom: ministere)&.id
        organisme.organisme_ministeres.create(ministere_id: ministere_id) if !ministere_id.nil?
      end
      end
      if row_data['operateur_nf'] == 'oui' || row_data['operateur_n'] == 'oui' || row_data['operateur_n1'] == 'oui' || row_data['operateur_n2'] == 'oui'
        operateur = Operateur.new(organisme_id: organisme.id)
        column_names_bis = %w[operateur_nf operateur_n operateur_n1 operateur_n2 presence_categorie nom_categorie]
        column_names_bis.each do |column_name|
          row_data[column_name] = convert_to_boolean(row_data[column_name])
        end
        operateur.attributes = row_data.slice(*column_names_bis)
        programme_id = Programme.find_by(numero: row_data['programme'][0, 3].to_i)&.id if row_data['programme']
        operateur.programme_id = programme_id
        operateur.mission_id = Mission.where(programme_id: programme_id).first.id if programme_id
        operateur.save
        if operateur.save
        selected_programmes = row_data['programmes_annexes'].to_s.split(' , ').map { |element| element.split(" - ").first.to_i } || []
        selected_programmes.each do |programme_numero|
          p_id = Programme.find_by(numero: programme_numero)&.id
          operateur.operateur_programmes.create(programme_id: p_id) if p_id
        end
        end
      end
    end
  end

  def self.convert_to_boolean(value)
    case value.to_s.downcase
    when 'oui'
      true
    when 'non'
      false
    when ''
      nil
    else
      value
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["acronyme", "admin_db_fonction", "admin_db_present", "admin_preca", "agent_comptable_present", "apu", "arrete_controle", "arrete_interdiction_odac", "arrete_nomination", "autorite_approbation", "autorite_controle", "bureau_id", "ciassp_n", "ciassp_n1", "comite_audit", "commentaire", "comptabilite_budgetaire", "controleur_ca", "controleur_id", "controleur_preca", "created_at", "date_creation", "date_dissolution", "date_previsionnelle_dissolution", "degre_gbcp", "delegation_approbation", "document_controle_date", "document_controle_lien", "document_controle_present", "effet_dissolution", "etat", "famille", "gbcp_1", "gbcp_3", "id", "ministere_id", "nature", "nature_controle", "nom", "odac_n", "odac_n1", "odal_n", "odal_n1", "presence_controle", "siren", "statut", "texte_institutif", "texte_reglementaire_controle", "texte_soumission_controle", "tutelle_financiere", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["bureau", "chiffres", "controleur", "ministere", "modifications", "operateur", "organisme_destinations", "organisme_ministeres", "organisme_rattachements", "control_documents"]
  end

  ransacker :nom, type: :string do
    Arel.sql("unaccent(organismes.\"nom\")")
  end

  ransacker :acronyme, type: :string do
    Arel.sql("unaccent(organismes.\"acronyme\")")
  end
end
