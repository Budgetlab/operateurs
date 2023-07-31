class OrganismeRattachement < ApplicationRecord
  belongs_to :organisme
  belongs_to :organisme_destination, class_name: 'Organisme'
end
