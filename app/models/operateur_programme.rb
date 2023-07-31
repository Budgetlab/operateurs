# frozen_string_literal: true

# Model OperateurProgramme Annexe
class OperateurProgramme < ApplicationRecord
  belongs_to :operateur
  belongs_to :programme
end
