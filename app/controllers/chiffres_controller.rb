# frozen_string_literal: true

# Controller Pages Chiffres
class ChiffresController < ApplicationController
  before_action :find_organisme, only: %i[index show_dates]
  def index
    @est_editeur = current_user == @organisme.controleur || current_user == @organisme.bureau
    @chiffres = @organisme.chiffres
    @date = Date.today.year
    liste_budgets(@date, @chiffres)
  end

  def show_dates
    @chiffres = @organisme.chiffres
    @date = params[:exercice_budgetaire].to_i
    liste_budgets(@date, @chiffres)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('tabs', partial: 'chiffres/tabs')
        ]
      end
    end
  end

  def new
    redirect_to root_path and return unless @statut_user == 'Bureau Sectoriel' || @statut_user == 'Controleur'

    @chiffre = Chiffre.new
    @organismes = if @statut_user == 'Controleur'
                    current_user.controleur_organismes.where(statut: 'valide', etat: 'Actif')
                  else
                    current_user.bureau_organismes.where(statut: 'valide', etat: 'Actif')
                  end
  end

  def select_comptabilite
    comptabilite = Organisme.where(id: params[:organisme])&.first&.comptabilite_budgetaire
    comptabilite = comptabilite != 'Non' if comptabilite

    response = { comptabilite: comptabilite }
    render json: response
  end

  def select_exercice
    date = params[:exercice]
    operateur = Organisme.where(id: params[:organisme])&.first&.operateur if params[:organisme]
    operateur = case date.to_i
                when Date.today.year + 1
                  operateur&.operateur_nf
                when Date.today.year
                  operateur&.operateur_n
                when Date.today.year - 1
                  operateur&.operateur_n1
                else
                  false
                end

    response = { operateur: operateur || false }
    render json: response
  end

  def create
    @chiffre = Chiffre.new(chiffre_params)
    if @chiffre.save
      redirect_to edit_chiffre_path(@chiffre)
    else
      render :new
    end
  end

  def edit
    @chiffre = Chiffre.find(params[:id])
    @organisme = @chiffre.organisme
    @steps = @chiffre.comptabilite_budgetaire == true ? 6 : 5
  end

  def update
    @chiffre = Chiffre.find(params[:id])
    @organisme = @chiffre.organisme
    if params[:chiffre][:statut] && params[:chiffre][:statut] != 'valide'
      step = params[:chiffre][:statut].to_i + 1
      params[:chiffre][:statut] = @chiffre.statut.to_i > params[:chiffre][:statut].to_i ? @chiffre.statut : params[:chiffre][:statut] # pour garder dernière étape sauvegardee si retour en arrière
    end
    @chiffre.update(chiffre_params)
    message = @chiffre.statut == 'valide' ? 'maj' : 'creation'
    redirect_path = @chiffre.statut == 'valide' ? organisme_chiffres_path(@organisme) : edit_chiffre_path(@chiffre, step: step)
    redirect_to redirect_path, flash: { notice: message }
  end

  def historique
    select_chiffres
    @exercices = @chiffres.pluck(:exercice_budgetaire).uniq
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def filtre_chiffres
    select_chiffres
    @exercices = @chiffres.pluck(:exercice_budgetaire).uniq
    @chiffres = @chiffres.select { |el| params[:budgets].include?(el.type_budget) } if params[:budgets] && params[:budgets].length != 3
    @chiffres = @chiffres.select { |el| params[:phases].include?(el.phase) } if params[:phases] && params[:phases].length != 3
    @chiffres = @chiffres.select { |el| params[:exercices].include?(el.exercice_budgetaire.to_s) } if params[:exercices] && params[:exercices].length != @exercices.length
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('table_historique', partial: 'chiffres/table_historique', locals: { chiffres: @chiffres }),
          turbo_stream.update('total_table', partial: 'chiffres/table_historique_total', locals: { total: @chiffres.length })
        ]
      end
    end
  end

  private

  def chiffre_params
    params.require(:chiffre).permit(:organisme_id, :type_budget, :exercice_budgetaire, :phase, :statut, :commentaire,
                                    :comptabilite_budgetaire, :operateur, :user_id, :emplois_plafond,
                                    :emplois_hors_plafond, :emplois_total, :emplois_plafond_rappel,
                                    :emplois_plafond_prenotifie, :emplois_schema, :emplois_schema_prenotifie,
                                    :emplois_non_remuneres, :emplois_titulaires, :emplois_titulaires_montant,
                                    :emplois_contractuels, :emplois_contractuels_montant, :emplois_autre_entite,
                                    :emplois_depenses_personnel, :emplois_charges_personnel, :credits_ae_total,
                                    :credits_ae_fonctionnement, :credits_ae_intervention, :credits_ae_investissement,
                                    :credits_cp_total, :credits_cp_fonctionnement, :credits_cp_intervention,
                                    :credits_cp_investissement, :credits_cp_operations, :credits_cp_recettes_flechees,
                                    :credits_subvention_sp, :credits_subvention_investissement_globalisee,
                                    :credits_subvention_investissement_flechee, :credits_financements_etat_autres,
                                    :credits_financements_etat_fleches, :credits_fiscalite_affectee,
                                    :credits_financements_publics_autres, :credits_financements_publics_fleches,
                                    :credits_recettes_propres_globalisees, :credits_recettes_propres_flechees,
                                    :credits_restes_a_payer, :tresorerie_finale_flechee, :tresorerie_finale_non_flechee,
                                    :tresorerie_finale, :tresorerie_variation, :tresorerie_variation_flechee,
                                    :tresorerie_variation_non_flechee, :tresorerie_min, :tresorerie_max,
                                    :tresorerie_min_date, :tresorerie_max_date, :commentaire_annexe,
                                    :capacite_autofinancement, :fonds_roulement_final, :fonds_roulement_variation,
                                    :fonds_roulement_inital, :fonds_roulement_besoin_initial,
                                    :fonds_roulement_besoin_final, :risque_insolvabilite)
  end

  def find_organisme
    @organisme = Organisme.find(params[:organisme_id])
  end

  def liste_budgets(exercice_budgetaire, chiffres)
    @budget_initial = filter_chiffres('Budget initial', exercice_budgetaire, chiffres)
    @budgets_rectificatifs = filter_chiffres('Budget rectificatif', exercice_budgetaire, chiffres)
    @compte_financier = filter_chiffres('Compte financier', exercice_budgetaire, chiffres)
  end

  def filter_chiffres(type_budget, exercice_budgetaire, chiffres)
    chiffres.select { |el| el.type_budget == type_budget && el.exercice_budgetaire == exercice_budgetaire }
  end

  def select_chiffres
    @organismes_id = if @statut_user == 'Controleur'
                       current_user.controleur_organismes.where(statut: 'valide', etat: 'Actif').pluck(:id)
                     elsif @statut_user == 'Bureau Sectoriel'
                       current_user.bureau_organismes.where(statut: 'valide', etat: 'Actif').pluck(:id)
                     else
                       Organisme.where(statut: 'valide', etat: 'Actif').pluck(:id)
                     end
    @chiffres = Chiffre.where(organisme_id: @organismes_id).includes(:organisme, :user).order(created_at: :desc)
  end
end
