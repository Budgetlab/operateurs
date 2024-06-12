class OrganismeRattachement < ApplicationRecord
  belongs_to :organisme
  belongs_to :organisme_destination, class_name: 'Organisme'

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "organisme_destination_id", "organisme_id", "updated_at"]
  end
  def self.ransackable_associations(auth_object = nil)
    ["organisme", "organisme_destination"]
  end
end
