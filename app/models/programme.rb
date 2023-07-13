# frozen_string_literal: true

# Model Programme
class Programme < ApplicationRecord
  has_many :missions
  has_many :operateurs
  has_many :operateur_programmes
end
