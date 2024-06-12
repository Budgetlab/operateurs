# frozen_string_literal: true

# Model Modification
class Modification < ApplicationRecord
  belongs_to :organisme
  belongs_to :user

  def self.ransackable_attributes(auth_object = nil)
    ["ancienne_valeur", "champ", "commentaire", "created_at", "id", "nom", "nouvelle_valeur", "organisme_id", "statut", "updated_at", "user_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user", "organisme"]
  end

  def self.modifications_count_by_controller(organisme_id)
    select("DATE(created_at) AS modification_date, statut, organisme_id, user_id, COUNT(*) AS modification_count")
      .where(organisme_id: organisme_id)
      .group("DATE(created_at), user_id, organisme_id, statut").order("DATE(created_at) DESC")
  end

end
