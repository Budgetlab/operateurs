# frozen_string_literal: true

# Model Operateur
class Operateur < ApplicationRecord
  belongs_to :organisme
  belongs_to :mission
  belongs_to :programme
  has_many :operateur_programmes, dependent: :destroy
end
