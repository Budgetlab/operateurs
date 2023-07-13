# frozen_string_literal: true

# Model Mission
class Mission < ApplicationRecord
  belongs_to :programme
  has_many :operateurs
end
