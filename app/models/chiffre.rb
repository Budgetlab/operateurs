# frozen_string_literal: true

# Model Chiffre
class Chiffre < ApplicationRecord
  belongs_to :organisme
  belongs_to :user
end
