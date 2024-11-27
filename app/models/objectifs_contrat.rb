class ObjectifsContrat < ApplicationRecord
  belongs_to :user
  belongs_to :organisme

  has_one_attached :document

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "debut", "fin", "id", "nom", "organisme_id", "updated_at", "user_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["document_attachment", "document_blob", "organisme", "user"]
  end
end
