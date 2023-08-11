# frozen_string_literal: true

# Controller Pages statiques
class PagesController < ApplicationController
  before_action :authenticate_user!
  def index
    @search_organismes = []
    relation = case @statut_user
               when '2B2O'
                 Organisme.all
               when 'Controleur'
                 current_user.controleur_organismes.where(statut: 'valide')
               when 'Bureau Sectoriel'
                 current_user.bureau_organismes.where(statut: 'valide')
                       end
    @organismes_last = relation ? relation.order(updated_at: :desc).limit(6) : []
  end

  def mentions_legales; end
  def accessibilite; end
  def donnees_personnelles; end
  def plan; end

  def reset_all
    redirect_to root_path and return unless @statut_user == '2B2O'

    OrganismeRattachement.destroy_all
    OrganismeMinistere.destroy_all
    OperateurProgramme.destroy_all
    Operateur.destroy_all
    Organisme.destroy_all
    redirect_to organismes_ajout_path
  end

end
