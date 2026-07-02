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
        ciassp_n: convert_to_boolean(row_data['CIASSP 2026']),
        ciassp_n1: convert_to_boolean(row_data['CIASSP 2025']),
        odac_n: convert_to_boolean(row_data['ODAC 2024']),
        odac_n1: convert_to_boolean(row_data['ODAC 2023']),
        odal_n: convert_to_boolean(row_data['ODAL 2024']),
        odal_n1: convert_to_boolean(row_data['ODAL 2023']),
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

  SKIP_COLS = %w[id created_at updated_at].freeze
  BOOL_COLS = %w[admin_db_present admin_preca agent_comptable_present apu ciassp_n ciassp_n1 comite_audit
                 controleur_ca controleur_preca delegation_approbation document_controle_present gbcp_1 gbcp_3
                 odac_n odac_n1 odal_n odal_n1 presence_controle tutelle_financiere].freeze
  DATE_COLS = %w[date_creation date_dissolution date_previsionnelle_dissolution].freeze
  INT_COLS  = %w[controleur_id bureau_id ministere_id].freeze
  FLOAT_COLS = %w[taux_cadrage_n taux_cadrage_n1].freeze

  def self.import_complet(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    counts = { organismes: 0, operateurs: 0, ministeres: 0, rattachements: 0 }

    ActiveRecord::Base.transaction do
      # --- Onglet 1 : Organismes ---
      sheet = spreadsheet.sheet(0)
      headers = sheet.row(1).map(&:to_s)
      updatable = headers - SKIP_COLS

      sheet.each_with_index do |row, idx|
        next if idx == 0
        data = Hash[headers.zip(row)]
        organisme = find_by(id: data['id'].to_i)
        next unless organisme

        attrs = updatable.each_with_object({}) do |col, h|
          val = data[col]
          h[col] = if BOOL_COLS.include?(col)
                     parse_bool_import(val)
                   elsif DATE_COLS.include?(col)
                     parse_date_import(val)
                   elsif INT_COLS.include?(col)
                     val.present? ? val.to_i : nil
                   elsif FLOAT_COLS.include?(col)
                     val.present? ? val.to_f : nil
                   else
                     val.to_s.presence
                   end
        end
        organisme.update!(attrs)
        counts[:organismes] += 1
      end

      # --- Onglet 2 : Opérateurs ---
      op_sheet = spreadsheet.sheet(1)
      op_headers = op_sheet.row(1).map(&:to_s)
      op_skip = %w[id created_at updated_at organisme_id]
      op_bool = %w[operateur_n operateur_n1 operateur_n2 operateur_nf presence_categorie]
      op_int  = %w[mission_id programme_id]

      op_sheet.each_with_index do |row, idx|
        next if idx == 0
        data = Hash[op_headers.zip(row)]
        organisme = find_by(id: data['organisme_id'].to_i)
        next unless organisme

        operateur = organisme.operateur || organisme.build_operateur
        (op_headers - op_skip).each do |col|
          val = data[col]
          operateur[col] = if op_bool.include?(col)
                             parse_bool_import(val)
                           elsif op_int.include?(col)
                             val.present? ? val.to_i : nil
                           else
                             val.to_s.presence
                           end
        end
        operateur.save!
        counts[:operateurs] += 1
      end

      # --- Onglet 3 : Co-tutelles ---
      om_sheet = spreadsheet.sheet(2)
      om_headers = om_sheet.row(1).map(&:to_s)
      om_rows = []
      om_sheet.each_with_index { |row, idx| next if idx == 0; om_rows << Hash[om_headers.zip(row)] }

      om_rows.map { |d| d['organisme_id'].to_i }.uniq.each do |org_id|
        find_by(id: org_id)&.organisme_ministeres&.destroy_all
      end
      om_rows.each do |data|
        org_id = data['organisme_id'].to_i
        min_id = data['ministere_id'].to_i
        next unless org_id > 0 && min_id > 0
        OrganismeMinistere.create!(organisme_id: org_id, ministere_id: min_id)
        counts[:ministeres] += 1
      end

      # --- Onglet 4 : Rattachements ---
      rat_sheet = spreadsheet.sheet(3)
      rat_headers = rat_sheet.row(1).map(&:to_s)
      rat_rows = []
      rat_sheet.each_with_index { |row, idx| next if idx == 0; rat_rows << Hash[rat_headers.zip(row)] }

      rat_rows.map { |d| d['organisme_id'].to_i }.uniq.each do |org_id|
        find_by(id: org_id)&.organisme_rattachements&.destroy_all
      end
      rat_rows.each do |data|
        org_id  = data['organisme_id'].to_i
        dest_id = data['organisme_destination_id'].to_i
        next unless org_id > 0 && dest_id > 0
        OrganismeRattachement.create!(organisme_id: org_id, organisme_destination_id: dest_id)
        counts[:rattachements] += 1
      end
    end

    counts
  end

  def self.parse_bool_import(val)
    return nil if val.nil? || val.to_s.strip == ''
    return val if val.is_a?(TrueClass) || val.is_a?(FalseClass)
    case val.to_s.strip.downcase
    when 'true', 'oui', '1' then true
    when 'false', 'non', '0' then false
    end
  end

  def self.parse_date_import(val)
    return nil if val.nil? || val.to_s.strip == ''
    return val if val.is_a?(Date)
    Date.parse(val.to_s)
  rescue ArgumentError
    nil
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
    ["bureau", "chiffres", "control_documents", "controleur", "enquete_reponses", "ministere", "modifications", "objectifs_contrats", "operateur", "organisme_destinations", "organisme_ministeres", "organisme_rattachements"]
  end

  ransacker :nom, type: :string do
    Arel.sql("unaccent(organismes.\"nom\")")
  end

  ransacker :acronyme, type: :string do
    Arel.sql("unaccent(organismes.\"acronyme\")")
  end
end
