# frozen_string_literal: true

# Controller Pages statiques
class PagesController < ApplicationController
  before_action :authenticate_user!
  def index
    @search_organismes = []
    @organismes_last = @statut_user == '2B2O' ? Organisme.order(updated_at: :desc).limit(6) : @statut_user == 'Controleur' ? current_user.controleur_organismes.where(statut: 'valide').order(updated_at: :desc).limit(6) : current_user.bureau_organismes.where(statut: 'valide').order(updated_at: :desc).limit(6)
  end

  def mentions_legales; end
  def accessibilite; end
  def donnees_personnelles; end
  def plan; end

  def reset_all
    OrganismeRattachement.destroy_all
    OrganismeMinistere.destroy_all
    OperateurProgramme.destroy_all
    Operateur.destroy_all
    Organisme.destroy_all
    redirect_to organismes_ajout_path
  end

end
