# frozen_string_literal: true

# Model OperateurProgramme Annexe
class OperateurProgramme < ApplicationRecord
  belongs_to :operateur
  belongs_to :programme

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "operateur_id", "programme_id", "updated_at"]
  end
  def self.ransackable_associations(auth_object = nil)
    ["operateur", "programme"]
  end
end
