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
      if organisme && [row_data['operateur_n'], row_data['operateur_n1'], row_data['operateur_n2']].any?('OUI')
        operateur = Operateur.where(organisme_id: organisme.id).first || Operateur.new(organisme_id: organisme.id)
        column_names_bis = %w[operateur_n operateur_n1 operateur_n2 presence_categorie nom_categorie]
        column_names_bis.each do |column_name|
          row_data[column_name] = convert_to_boolean(row_data[column_name])
        end
        operateur.attributes = row_data.slice(*column_names_bis)

        if row_data['programme']
          programme = Programme.find_by(numero: row_data['programme'].to_i)
          operateur.programme_id = programme&.id
          operateur.mission_id = Mission.find_by(programme_id: programme&.id)&.id if programme
        end

        if operateur.save
          operateur.operateur_programmes.destroy_all
          selected_programmes = (row_data['programmes_annexes'].to_s || '').split('-').map(&:to_i)
          selected_programmes.each do |programme_numero|
            p_id = Programme.find_by(numero: programme_numero)&.id
            operateur.operateur_programmes.create(programme_id: p_id) if p_id
          end
        end
      elsif organisme
        organisme.operateur&.destroy
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
    ["created_at", "id", "id_value", "mission_id", "nom_categorie", "operateur_n", "operateur_n1", "operateur_n2", "operateur_nf", "organisme_id", "presence_categorie", "programme_id", "updated_at"]
  end
end
