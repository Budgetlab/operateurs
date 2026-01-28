# frozen_string_literal: true

# Model Mission
class Mission < ApplicationRecord
  belongs_to :programme
  has_many :operateurs

  def self.import(file)
    data = Roo::Spreadsheet.open(file.path)
    headers = data.row(1) # get header row
    data.each_with_index do |row, idx|
      next if idx == 0 # skip header

      row_data = Hash[[headers, row].transpose]

      # Trouver ou créer le programme et mettre à jour son intitulé
      programme = Programme.find_or_initialize_by(numero: row_data['Code Programme'].to_i)
      programme.nom = row_data['Intitulé de Programme'].to_s
      programme.save

      # Trouver ou créer la mission associée et mettre à jour son nom
      mission = Mission.find_or_initialize_by(programme_id: programme.id)
      mission.nom = row_data['Mission'].to_s
      mission.save
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "nom", "programme_id", "statut", "updated_at"]
  end
  def self.ransackable_associations(auth_object = nil)
    ["operateurs", "programme"]
  end
end
