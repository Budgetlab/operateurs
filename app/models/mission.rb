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
      Programme.where(numero: row_data['Code Programme'].to_i).first_or_create do |programme|
        programme.nom = row_data['Intitulé de Programme'].to_s
        programme.numero = row_data['Code Programme'].to_i
      end
      mission = Mission.new
      mission.nom = row_data['Mission'].to_s
      mission.programme_id = Programme.where(nom: row_data['Intitulé de Programme'].to_s).first.id
      mission.save
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "nom", "programme_id", "updated_at"]
  end
  def self.ransackable_associations(auth_object = nil)
    ["operateurs", "programme"]
  end
end
