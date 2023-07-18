# frozen_string_literal: true

# Model Modification
class Modification < ApplicationRecord
  belongs_to :organisme
  belongs_to :user
end
