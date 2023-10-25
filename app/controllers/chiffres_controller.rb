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
    @organisme = Organisme.find(params[:chiffre][:organisme_id])
    @can_edit = @organisme && (current_user == @organisme.controleur || current_user == @organisme.bureau)
    redirect_to root_path and return unless @can_edit

    @chiffre_exist = !Chiffre.where(organisme_id: @organisme.id,
                                   exercice_budgetaire: params[:chiffre][:exercice_budgetaire],
                                   type_budget: params[:chiffre][:type_budget]).empty?
    if @chiffre_exist
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new_content', partial: 'chiffres/form_error', locals: { organisme: @organisme })
          ]
        end
      end
    else
      @chiffre = Chiffre.new(chiffre_params)
      if @chiffre.save
        redirect_to edit_chiffre_path(@chiffre)
      else
        render :new
      end
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
    @can_edit = @organisme && (current_user == @organisme.controleur || current_user == @organisme.bureau)
    redirect_to root_path and return unless @can_edit

    if params[:chiffre][:statut] && params[:chiffre][:statut] != 'valide'
      step = params[:chiffre][:statut].to_i + 1
      params[:chiffre][:statut] = @chiffre.statut.to_i > params[:chiffre][:statut].to_i ? @chiffre.statut : params[:chiffre][:statut] # pour garder dernière étape sauvegardee si retour en arrière
    end
    @chiffre.update(chiffre_params)
    message = @chiffre.statut == 'valide' ? 'maj' : 'creation'
    redirect_path = @chiffre.statut == 'valide' ? organisme_chiffres_path(@organisme) : edit_chiffre_path(@chiffre, step: step)
    redirect_to redirect_path, flash: { notice: message }
  end

  def update_phase
    @chiffre = Chiffre.find(params[:id])
    @organisme = @chiffre.organisme
    @can_edit = @organisme && (current_user == @organisme.controleur || current_user == @organisme.bureau)
    redirect_to root_path and return unless @can_edit && params[:phase]

    if params[:phase] == 'Budget non approuvé'
      @chiffre.destroy
      redirect_to organisme_chiffres_path(@organisme)
    else
      @chiffre.update(phase: params[:phase])
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('content_phase', partial: 'chiffres/content_phase', locals: { chiffre: @chiffre })
          ]
        end
      end
    end
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
    @chiffres = @chiffres.select { |el| params[:phases].include?(el.phase) } if params[:phases] && params[:phases].length != 4
    @chiffres = @chiffres.select { |el| params[:exercices].include?(el.exercice_budgetaire.to_s) } if params[:exercices] && params[:exercices].length != @exercices.length
    if params[:risque_insolvabilites] && params[:risque_insolvabilites].include?("Brouillon")
      @chiffres = @chiffres.select { |el| params[:risque_insolvabilites].include?(el.risque_insolvabilite) || el.statut != 'valide'}
    else
      @chiffres = @chiffres.select { |el| params[:risque_insolvabilites].include?(el.risque_insolvabilite) } if params[:risque_insolvabilites] && params[:risque_insolvabilites].length != 5
    end
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
                                    :fonds_roulement_besoin_final, :risque_insolvabilite, :charges_fonctionnement,
                                    :charges_intervention, :charges_non_decaissables, :produits_subventions_etat,
                                    :produits_fiscalite_affectee, :produits_subventions_autres, :produits_autres,
                                    :produits_non_encaissables, :emplois_cout_total, :emplois_cout_investissements,
                                    :ressources_financement_etat, :ressources_autres, :decaissements_emprunts,
                                    :encaissements_emprunts, :decaissements_operations, :encaissements_operations,
                                    :decaissements_autres, :encaissements_autres, :ressources_total)
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
    @organismes_id = current_user.bureau_organismes.where(statut: 'valide', etat: 'Actif').pluck(:id) if @statut_user == 'Bureau Sectoriel'
    @chiffres = if @statut_user == 'Controleur'
                  current_user.chiffres.includes(:organisme).order(created_at: :desc)
                elsif @statut_user == 'Bureau Sectoriel'
                  Chiffre.where(organisme_id: @organismes_id).includes(:organisme).order(created_at: :desc)
                else
                  Chiffre.all.includes(:organisme).order(created_at: :desc)
                end
  end
end
