class ControlDocument < ApplicationRecord
  belongs_to :user
  belongs_to :organisme

  has_one_attached :document

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "name", "organisme_id", "signature_date", "updated_at", "user_id"]
  end
end
