class Enquete < ApplicationRecord
  has_many :enquete_questions, dependent: :destroy
  has_many :enquete_reponses, dependent: :destroy

  has_one_attached :document

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "annee", "updated_at"]
  end
  def self.ransackable_associations(auth_object = nil)
    ["enquete_questions", "enquete_reponses"]
  end
end
