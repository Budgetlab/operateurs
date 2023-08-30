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
      next if row_data['Siren'].blank?
      organisme = Organisme.find_by(siren: row_data['Siren'].to_s)
      if organisme
        operateur = Operateur.where(organisme_id: organisme.id).first || Operateur.new(organisme_id: organisme.id)
        column_names_excel = %w[operateur_n operateur_n1 operateur_n2 presence_categorie nom_categorie]
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
end
