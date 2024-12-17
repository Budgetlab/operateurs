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
  has_many :enquete_reponses, dependent: :destroy
  has_many :objectifs_contrats, dependent: :destroy

  def self.import(file)
    data = Roo::Spreadsheet.open(file.path)
    headers = data.row(1) # get header row
    puts data.column(5)[1..-1].map do |cell|
      cell.to_s.strip.gsub(/\s+/, '') unless cell.nil?
    end
    sirens_in_file = data.column(5)[1..-1].map do |cell|
      value = cell.to_s.strip.gsub(/\s+/, '')
      value unless cell.nil? || value == "Nonrenseigné"
    end.compact
    Organisme.where(siren: nil).destroy_all
    Organisme.where.not(siren: sirens_in_file)&.destroy_all
    data.each_with_index do |row, idx|
      next if idx == 0 # skip header

      row_data = Hash[[headers, row].transpose]
      # Nettoyage du SIREN (suppression des espaces)
      siren = row_data['Siren'] != ' Non renseigné' ? row_data['Siren']&.strip&.gsub(/\s+/, '') : nil

      # Trouver ou initialiser l'organisme
      organisme = siren.nil? ? Organisme.find_or_initialize_by(nom: row_data['Nom']) : Organisme.find_or_initialize_by(siren: siren.to_s)
      # Mettre à jour les attributs
      organisme.assign_attributes(
        siren: convert_to_boolean(siren),
        nom: row_data['Nom'],
        acronyme: convert_to_boolean(row_data['Acronyme']),
        etat: row_data['État'],
        date_creation: parse_date(row_data['Date création']),
        famille: row_data['Famille'],
        nature: row_data['Nature juridique'],
        date_previsionnelle_dissolution: parse_date(row_data['Date prévisionnelle dissolution']),
        date_dissolution: parse_date(row_data['Date dissolution']),
        effet_dissolution: convert_to_boolean(row_data['Effet dissolution']),
        bureau_id: User.find_by(nom: row_data['Bureau rattachement'].to_s)&.id,
        texte_institutif: convert_to_boolean(row_data['Textes institutifs']),
        commentaire: row_data['Commentaire'],
        gbcp_1: convert_to_boolean(row_data['GBCP Titre I']),
        agent_comptable_present: convert_to_boolean(row_data['Agent comptable']),
        degre_gbcp: convert_to_boolean(row_data['Champ application GBCP']),
        gbcp_3: convert_to_boolean(row_data['GBCP Titre III']),
        comptabilite_budgetaire: row_data['Comptabilité budgétaire'],
        presence_controle: convert_to_boolean(row_data['Présence contrôle']),
        controleur_id: User.find_by(nom: row_data['Contrôleur Référent OPERA'].to_s)&.id,
        nature_controle: convert_to_boolean(row_data['Nature contrôle']),
        texte_soumission_controle: convert_to_boolean(row_data['Référence texte soumission contrôle']),
        autorite_controle: convert_to_boolean(row_data['Autorité contrôle']),
        texte_reglementaire_controle: convert_to_boolean(row_data['Texte réglementaire désignation autorité contrôle']),
        arrete_controle: convert_to_boolean(row_data['Référence arrêté contrôle']),
        document_controle_present: convert_to_boolean(row_data['Document contrôle']),
        arrete_nomination: convert_to_boolean(row_data['Référence arrêté nomination commissaire gouvernement']),
        tutelle_financiere: convert_to_boolean(row_data['Tutelle financière MCP']),
        delegation_approbation: convert_to_boolean(row_data['Délégation approbation BI/BR/CF']),
        autorite_approbation: convert_to_boolean(row_data['Autorité chargée approbation BI/BR/CF']),
        ministere_id: Ministere.find_by(nom: row_data['Ministère tutelle'].to_s)&.id,
        admin_db_present: convert_to_boolean(row_data['Admin DB']),
        admin_db_fonction: convert_to_boolean(row_data['Fonction Admin']),
        admin_preca: convert_to_boolean(row_data['Présence DB préCA']),
        controleur_preca: convert_to_boolean(row_data['Présence Controleur préCA']),
        controleur_ca: convert_to_boolean(row_data['Présence Controleur CA']),
        comite_audit: convert_to_boolean(row_data['Comité Audit Risques']),
        apu: convert_to_boolean(row_data['APU']),
        arrete_interdiction_odac: convert_to_boolean(row_data['Arrêté Interdiction emprunt ODAC']),
        ciassp_n: convert_to_boolean(row_data['CIASSP 2024']),
        ciassp_n1: convert_to_boolean(row_data['CIASSP 2023']),
        odac_n: convert_to_boolean(row_data['ODAC 2022']),
        odac_n1: convert_to_boolean(row_data['ODAC 2021']),
        odal_n: convert_to_boolean(row_data['ODAL 2022']),
        odal_n1: convert_to_boolean(row_data['ODAL 2021']),
        statut: 'valide',
        )
      # Sauvegarder uniquement si des modifications ont été apportées
      organisme.save if organisme.changed?

      ministere_array = row_data['Ministères co-tutelle'].tr("[]'", '').split(',').map { |item| item.strip.gsub('"', '') } || []
      organisme.organisme_ministeres&.destroy_all
      ministere_array.each do |ministere|
        ministere_id = Ministere.find_by(nom: ministere)&.id
        organisme.organisme_ministeres.create(ministere_id: ministere_id)
      end

      if row_data['Programme chef file'] == 'N/A'
        organisme.operateur&.destroy
      else
        operateur = Operateur.find_or_initialize_by(organisme_id: organisme.id)
        programme_id = Programme.find_by(numero: row_data['Programme chef file'].to_i)&.id if row_data['Programme chef file']
        mission_id = Mission.where(programme_id: programme_id).first.id if programme_id
        operateur.assign_attributes(
          operateur_nf: convert_to_boolean(row_data['Opérateur 2025']),
          operateur_n: convert_to_boolean(row_data['Opérateur 2024']),
          operateur_n1: convert_to_boolean(row_data['Opérateur 2023']),
          operateur_n2: convert_to_boolean(row_data['Opérateur 2022']),
          presence_categorie: convert_to_boolean(row_data['Appartenance catégorie opérateurs']),
          nom_categorie: convert_to_boolean(row_data['Nom catégorie']),
          programme_id: programme_id,
          mission_id: mission_id,
          )
        operateur.save if operateur.changed?
        operateur.operateur_programmes&.destroy_all
        selected_programmes = row_data['Autres Programmes financeurs'].tr('[]', '').split(',').map(&:to_i) || []
        selected_programmes.each do |programme_numero|
          p_id = Programme.find_by(numero: programme_numero.to_i)&.id
          operateur.operateur_programmes.create(programme_id: p_id) if p_id
        end
      end
    end
  end

  def self.convert_to_boolean(value)
    case value
    when 'Oui'
      true
    when 'Non'
      false
    when '', 'Non renseigné', 'N/A'
      nil
    else
      value
    end
  end

  def self.parse_date(date_string)
    return nil if date_string.blank? || date_string == 'N/A' || date_string == 'Non renseigné'
    Date.parse(date_string) rescue nil
  end

  def self.ransackable_attributes(auth_object = nil)
    ["acronyme", "admin_db_fonction", "admin_db_present", "admin_preca", "agent_comptable_present", "apu", "arrete_controle", "arrete_interdiction_odac", "arrete_nomination", "autorite_approbation", "autorite_controle", "bureau_id", "ciassp_n", "ciassp_n1", "comite_audit", "commentaire", "comptabilite_budgetaire", "controleur_ca", "controleur_id", "controleur_preca", "created_at", "date_creation", "date_dissolution", "date_previsionnelle_dissolution", "degre_gbcp", "delegation_approbation", "document_controle_present", "effet_dissolution", "etat", "famille", "gbcp_1", "gbcp_3", "id", "ministere_id", "nature", "nature_controle", "nom", "odac_n", "odac_n1", "odal_n", "odal_n1", "presence_controle", "siren", "statut","taux_cadrage_n", "taux_cadrage_n1", "texte_institutif", "texte_reglementaire_controle", "texte_soumission_controle", "tutelle_financiere", "updated_at"]
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
