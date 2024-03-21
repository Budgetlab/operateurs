# frozen_string_literal: true

# Model Programme
class Programme < ApplicationRecord
  has_many :missions
  has_many :operateurs
  has_many :operateur_programmes

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "nom", "numero", "updated_at"]
  end
end
