# frozen_string_literal: true

# Model Operateur
class Operateur < ApplicationRecord
  belongs_to :organisme
  belongs_to :mission
  belongs_to :programme
  has_many :operateur_programmes, dependent: :destroy

  def self.import(file)
    data = Roo::Spreadsheet.open(file.path)
    headers = data.row(1) # get header row
    data.each_with_index do |row, idx|
      next if idx == 0 # skip header

      row_data = Hash[[headers, row].transpose]
      siren = row_data['siren'].to_s
      next if siren.blank?

      organisme = Organisme.find_by(siren: siren)
      # Dynamic year mapping: operateur_n = current year, n1 = year-1, n2 = year-2
      current_year = Date.today.year
      year_map = { 'operateur_n' => current_year, 'operateur_n1' => current_year - 1, 'operateur_n2' => current_year - 2 }
      new_years = year_map.select { |col, _| row_data[col].to_s.upcase == 'OUI' }.values
      if organisme && new_years.any?
        operateur = Operateur.where(organisme_id: organisme.id).first || Operateur.new(organisme_id: organisme.id)
        existing_years = operateur.annees || []
        merged_years = (existing_years + new_years).uniq.sort
        is_active = new_years.any? { |y| y >= current_year }
        operateur.annees = merged_years
        operateur.presence_categorie = convert_to_boolean(row_data['presence_categorie'])
        operateur.nom_categorie = row_data['nom_categorie']

        if row_data['programme']
          programme = Programme.find_by(numero: row_data['programme'].to_i)
          operateur.programme_id = programme&.id
          operateur.mission_id = Mission.find_by(programme_id: programme&.id)&.id if programme
        end

        if operateur.save
          organisme.update(operateur_actif: is_active)
          operateur.operateur_programmes.destroy_all
          selected_programmes = (row_data['programmes_annexes'].to_s || '').split('-').map(&:to_i)
          selected_programmes.each do |programme_numero|
            p_id = Programme.find_by(numero: programme_numero)&.id
            operateur.operateur_programmes.create(programme_id: p_id) if p_id
          end
        end
      elsif organisme
        organisme.operateur&.destroy
        organisme.update(operateur_actif: false)
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

  # Returns all years this operator was/is active.
  # Active operators store the start year of contiguous range; this expands it to current year.
  # Inactive operators store all individual years directly.
  def toutes_annees
    return [] if annees.blank?

    sorted = annees.sort
    return sorted unless organisme.operateur_actif

    active_start = sorted.last
    past_years   = sorted[0...-1]
    active_range = (active_start..Date.today.year).to_a
    (past_years + active_range).uniq.sort
  end

  # Returns true if the operator was active in the given year.
  def operateur_pour_annee?(annee)
    toutes_annees.include?(annee)
  end

  # Activates the operator for the given year.
  # Adds the year to annees and sets operateur_actif on the associated organisme.
  def activer!(annee)
    raise ArgumentError, "annee must be an integer" unless annee.is_a?(Integer)

    transaction do
      self.annees = (annees + [annee]).uniq.sort
      save!
      organisme.update!(operateur_actif: true)
    end
  end

  # Deactivates the operator, expanding the active range into individual years up to annee_fin.
  # Sets operateur_actif to false on the associated organisme.
  def desactiver!(annee_fin)
    raise ArgumentError, "annee_fin must be an integer" unless annee_fin.is_a?(Integer)
    return organisme.update!(operateur_actif: false) if annees.blank?

    transaction do
      sorted = annees.sort
      active_start = sorted.last
      past_years   = sorted[0...-1]
      expanded = (past_years + (active_start..annee_fin).to_a).uniq.sort
      self.annees = expanded
      save!
      organisme.update!(operateur_actif: false)
    end
  end

  # Converts the flat annees array into a list of {de:, a:} period hashes.
  # The last period has a: nil if the operator is currently active.
  def annees_en_periodes
    return [] if annees.blank?

    sorted = annees.sort
    periodes = []
    debut = sorted.first
    prev  = sorted.first

    sorted.each_cons(2) do |a, b|
      if b == a + 1
        prev = b
      else
        periodes << { de: debut, a: prev }
        debut = b
        prev  = b
      end
    end

    # Last period: open-ended if active, closed otherwise
    if organisme.operateur_actif
      periodes << { de: debut, a: nil }
    else
      periodes << { de: debut, a: prev }
    end

    periodes
  end

  def self.ransackable_attributes(auth_object = nil)
    ["annees", "created_at", "id", "id_value", "mission_id", "nom_categorie", "organisme_id", "presence_categorie", "programme_id", "updated_at"]
  end
  def self.ransackable_associations(auth_object = nil)
    ["mission", "operateur_programmes", "organisme", "programme"]
  end
end
