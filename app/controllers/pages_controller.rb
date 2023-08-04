# frozen_string_literal: true

# Controller Pages statiques
class PagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_famille, only: [:index]
  def index
    @organismes = []
    @organismes_last = @familles.nil? ? Organisme.order(updated_at: :desc).limit(6) : Organisme.where(famille: @familles, statut: 'valide').order(updated_at: :desc).limit(6)
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

  private

  def set_famille
    if @statut_user == 'Controleur'
      @familles = current_user.controleur_organismes.pluck(:famille).uniq
    elsif @statut_user == 'Bureau Sectoriel'
      @familles = current_user.bureau_organismes.pluck(:famille).uniq
    end
  end
end
