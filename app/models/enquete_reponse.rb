class EnqueteReponse < ApplicationRecord
  belongs_to :organisme
  belongs_to :enquete

  def self.import(file)
    data = Roo::Spreadsheet.open(file.path)
    question_numbers = data.row(1)  # Row 1 for question numbers
    question_titles = data.row(2)   # Row 2 for question titles
    # Récupérer ou créer l'enquête pour l'année spécifiée
    enquete = Enquete.find_or_create_by(annee: question_titles[0].to_i) # premiere cellule

    enquete.enquete_reponses.destroy_all # supp et mettre à jour
    enquete.enquete_questions.destroy_all
    # First, process question headers to populate EnqueteQuestion
    enquete_questions_map = {} # Map question titles to question IDs
    question_titles.each_with_index do |title, idx|
      number = question_numbers[idx]
      next if title.nil? || number.nil? # Skip if there's no title or question number

      # Create or find the question by title and number
      question = EnqueteQuestion.find_or_create_by!(nom: title, numero: number, enquete_id: enquete.id)
      enquete_questions_map[title] = question.id
    end

    # Tableau pour collecter les SIREN non trouvés
    siren_non_trouves = []

    data.each_with_index do |row, idx|
      next if idx < 2 # skip header

      row_data = Hash[[question_titles, row].transpose] # Associer les headers et les valeurs des colonnes
      # Récupérer l'organisme par SIREN
      organisme = Organisme.where(siren: row_data['SIREN'].to_s).first
      unless organisme
        siren_non_trouves << row_data['SIREN']
        next
      end

      # Construire un hash pour les réponses
      reponses = {}
      question_titles.each do |header|
        question_id = enquete_questions_map[header]
        next unless question_id # Si la question n'existe pas, continuer à la prochaine colonne
        # Stocker la réponse dans le hash
        reponses[question_id] = row_data[header].to_s # Utilise l'ID de la question comme clé
      end
      # Trouver ou initialiser la réponse d'enquête
      enquete_reponse = EnqueteReponse.find_or_initialize_by(organisme: organisme, enquete: enquete)
      # Mettre à jour les réponses
      enquete_reponse.reponses = reponses
      enquete_reponse.save!
    end

    # Afficher tous les SIREN non trouvés à la fin
    if siren_non_trouves.any?
      puts "\n=========================================="
      puts "SIREN non trouvés (#{siren_non_trouves.length}) :"
      puts siren_non_trouves.join(', ')
      puts "==========================================\n"
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "enquete_id", "id", "organisme_id", "reponses", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["enquete", "organisme", "document_pdf_attachment", "document_pdf_blob"]
  end
end
