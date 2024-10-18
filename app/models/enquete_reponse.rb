class EnqueteReponse < ApplicationRecord
  belongs_to :organisme
  belongs_to :enquete

  has_one_attached :document_pdf
  def self.import(file)
    data = Roo::Spreadsheet.open(file.path)
    headers = data.row(1) # get header row
    data.each_with_index do |row, idx|
      next if idx == 0 # skip header
      row_data = Hash[[headers, row].transpose] # Associer les headers et les valeurs des colonnes
      # Récupérer l'organisme par SIREN
      organisme = Organisme.where(siren: row_data['SIREN'].to_s).first
      next unless organisme

      # Récupérer ou créer l'enquête pour l'année spécifiée
      enquete = Enquete.find_by(annee: row_data['Annee'].to_i)
      # Construire un hash pour les réponses
      reponses = {}
      headers.each do |header|
        puts header
        question = enquete.enquete_questions.where(nom: header).first
        puts question.nil?
        next unless question # Si la question n'existe pas, continuer à la prochaine colonne

        # Stocker la réponse dans le hash
        reponses[question.id] = row_data[header].to_s # Utilise l'ID ou le titre de la question comme clé
      end
      # Trouver ou initialiser la réponse d'enquête
      enquete_reponse = EnqueteReponse.find_or_initialize_by(organisme: organisme, enquete: enquete)
      # Mettre à jour les réponses
      enquete_reponse.reponses = reponses
      enquete_reponse.save!
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "enquete_id", "id", "organisme_id", "reponses", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["enquete", "organisme", "document_pdf_attachment", "document_pdf_blob"]
  end
end
