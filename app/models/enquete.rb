class Enquete < ApplicationRecord
  has_many :enquete_questions, dependent: :destroy
  has_many :enquete_reponses, dependent: :destroy

  has_one_attached :document
  def self.ransackable_associations(auth_object = nil)
    ["document_attachment", "document_blob", "enquete_questions", "enquete_reponses"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["annee", "created_at", "id", "id_value", "updated_at"]
  end

end
