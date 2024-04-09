# frozen_string_literal: true

# Module fonction pour redirection
module Authentication
  extend ActiveSupport::Concern

  private

  def redirect_unless_admin
    redirect_to root_path unless @statut_user == '2B2O'
  end
end
