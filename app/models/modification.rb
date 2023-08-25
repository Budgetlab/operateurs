# frozen_string_literal: true

# Model Modification
class Modification < ApplicationRecord
  belongs_to :organisme
  belongs_to :user

  def self.modifications_count_by_controller
    select("DATE(created_at) AS modification_date, statut, organisme_id, user_id, COUNT(*) AS modification_count")
      .group("DATE(created_at), user_id, organisme_id, statut").order("DATE(created_at) DESC")
  end
end
