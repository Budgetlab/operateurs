# frozen_string_literal: true

# Controller Pages statiques
class PagesController < ApplicationController
  before_action :authenticate_user!
  def index
    # Fetch all organisms relevant to user's permissions, including those in extended families
    extended_family_organisms = fetch_extended_family_organisms
    @search_organismes = extended_family_organisms.order(:nom).pluck(:id, :nom, :acronyme)
    # fetch last 6 updated organisms of the user
    @organismes_user = fetch_user_organisms(extended_family_organisms)
    @organismes_last = @organismes_user ? @organismes_user.order(updated_at: :desc).limit(4).pluck(:id, :nom, :acronyme, :updated_at, :nature, :famille, :etat, :statut) : []
    @chiffres = Chiffre.where(statut: 'valide').where(organisme_id: @organismes_user.pluck(:id))
    @organismes_user_active = @statut_user == "2B2O" ? @organismes_user.where(etat: "Actif").where.not(controleur_id: current_user.id) : @organismes_user.where(etat: "Actif")
    @chiffres_bi_2024 = calculate_chiffres_budget_exercice(@chiffres, @organismes_user_active, 2024, 'Budget initial')
    @chiffres_cf_2023 = calculate_chiffres_budget_exercice(@chiffres, @organismes_user_active, 2023, 'Compte financier')
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
    organisms
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
  def calculate_chiffres_budget_exercice(chiffres, organismes, exercice_budgetaire, type_budget)
    chiffres_budget = []
    risques = ["Situation saine","Situation saine a priori mais à surveiller",'Risque d’insoutenabilité à moyen terme','Risque d’insoutenabilité élevé']
    chiffres_selected = chiffres.where(exercice_budgetaire: exercice_budgetaire, type_budget: type_budget)
    risques.each do |risque|
      chiffres_budget << chiffres_selected.where(risque_insolvabilite: risque)&.length
    end
    chiffres_empty = organismes&.length - chiffres_selected&.length
    chiffres_budget << chiffres_empty
    chiffres_budget
  end

end
