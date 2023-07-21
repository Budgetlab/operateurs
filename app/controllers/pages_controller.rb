# frozen_string_literal: true

# Controller Pages statiques
class PagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_famille, only: [:index]
  def index
    @organismes = []
    @organismes_last = @familles.nil? ? Organisme.order(updated_at: :desc).limit(6) : Organisme.where(famille: @familles).order(updated_at: :desc).limit(6)
  end

  def mentions_legales; end
  def accessibilite; end
  def donnees_personnelles; end
  def plan; end

  private

  def set_famille
    if current_user.statut == 'Controleur'
      @familles = current_user.controleur_organismes.pluck(:famille).uniq
    elsif current_user.statut == 'Bureau Sectiorel'
      @familles = current_user.bureau_organismes.pluck(:famille).uniq
    end
  end
end
