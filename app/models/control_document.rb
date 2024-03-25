class ControlDocument < ApplicationRecord
  belongs_to :user
  belongs_to :organisme

  has_one_attached :document
end
