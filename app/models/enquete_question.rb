class EnqueteQuestion < ApplicationRecord
  belongs_to :enquete

  def self.import(file)
    data = Roo::Spreadsheet.open(file.path)
    headers = data.row(1) # get header row
    data.each_with_index do |row, idx|
      next if idx == 0 # skip header
      row_data = Hash[[headers, row].transpose]
      enquete = Enquete.find_or_create_by(annee: row_data['Annee'].to_i)
      EnqueteQuestion.where(numero: row_data['Numero'].to_i, enquete_id: enquete.id).first_or_create do |question|
        question.nom = row_data['Nom'].to_s
        question.categorie = row_data['Categorie'].to_s
        question.numero = row_data['Numero'].to_i
      end
    end
  end

  def self.ransackable_associations(auth_object = nil)
    ["enquete","enquete_reponses"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["enquete_id", "created_at", "id", "nom", "numero", "updated_at", "categorie"]
  end

end
