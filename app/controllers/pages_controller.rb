# frozen_string_literal: true

# Controller Pages statiques
class PagesController < ApplicationController
  before_action :authenticate_user!
  def index
    # Fetch all organisms relevant to user's permissions, including those in extended families
    extended_family_organisms = fetch_extended_family_organisms
    @search_organismes = extended_family_organisms.pluck(:id, :nom, :acronyme)
    # fetch last 6 updated organisms of the user
    organismes_user = fetch_user_organisms(extended_family_organisms)
    @organismes_last = organismes_user ? organismes_user.order(updated_at: :desc).limit(6).pluck(:id, :nom, :acronyme, :updated_at, :nature, :famille, :etat, :statut) : []
  end

  def mentions_legales; end
  def accessibilite; end
  def donnees_personnelles; end

  def plan; end

  private

  # filtre édition + lecture :récuperer les organismes qui lui appartiennent + ceux de la même famille (excluant aucune)
  # (attention si on ne prend que ceux des familles en commune on oublie les siens avec famille aucune)
  def fetch_extended_family_organisms
    organisms = Organisme.all.includes(:controleur, :bureau)
    case @statut_user
    when 'Controleur'
      organisms = organisms.where(statut: 'valide').where('controleur_id = :user_id OR famille IN (:familles)', user_id: current_user.id, familles: @familles)
    when 'Bureau Sectoriel'
      organisms = organisms.where(statut: 'valide')
    end
    organisms.order(:nom)
  end

  # fetch only those corresponding to the user
  def fetch_user_organisms(organisms)
    case @statut_user
    when '2B2O'
      organisms
    when 'Controleur'
      organisms.where(controleur_id: current_user.id)
    when 'Bureau Sectoriel'
      organisms.where(bureau_id: current_user.id)
    end
  end

end
