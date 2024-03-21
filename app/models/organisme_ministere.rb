class OrganismeMinistere < ApplicationRecord
  belongs_to :organisme
  belongs_to :ministere

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "ministere_id", "organisme_id", "updated_at"]
  end
  def self.ransackable_associations(auth_object = nil)
    ["ministere", "organisme"]
  end
end
