# frozen_string_literal: true

# Model Ministere
class Ministere < ApplicationRecord
  has_many :organismes
  has_many :organisme_ministeres
  def self.import(file)
    data = Roo::Spreadsheet.open(file.path)
    headers = data.row(1) # get header row
    data.each_with_index do |row, idx|
      next if idx == 0 # skip header

      row_data = Hash[[headers, row].transpose]
      Ministere.where(nom: row_data['nom'].to_s).first_or_create do |ministere|
        ministere.nom = row_data['nom'].to_s
      end
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "nom", "updated_at"]
  end
end
