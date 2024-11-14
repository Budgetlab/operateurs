class EnqueteQuestion < ApplicationRecord
  belongs_to :enquete

  def self.ransackable_associations(auth_object = nil)
    ["enquete","enquete_reponses"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["enquete_id", "created_at", "id", "nom", "numero", "updated_at"]
  end

end
