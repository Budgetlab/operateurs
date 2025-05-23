# frozen_string_literal: true

# Module fonction pour redirection
module Authentication
  extend ActiveSupport::Concern

  private

  def redirect_unless_controleur
    redirect_to root_path unless @statut_user == 'Controleur'
  end
end
