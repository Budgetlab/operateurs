# frozen_string_literal: true

# Controller Pages Chiffres
class ChiffresController < ApplicationController
  include Authentication
  before_action :authenticate_user!
  before_action :find_organisme, only: %i[index show_dates restitutions]
  before_action :find_chiffre_and_organisme, only: %i[edit update update_phase destroy open_phase show]
  before_action :redirect_unless_access, only: %i[index restitutions]
  before_action :redirect_unless_controleur, only: :new
  before_action :redirect_unless_can_edit, only: %i[edit update destroy]

  # page des chiffres clés de l'organisme
  def index
    # Check if the logged-in user is the "controller" of the organism, and store the result in @est_editeur
    @est_editeur = current_user == @organisme.controleur
    # Fetch all "chiffres" attached to the organism and sort them descendingly by "exercice_budgetaire"
    @chiffres = @organisme.chiffres.order(exercice_budgetaire: :desc)
    # Establish which "exercice_budgetaire" should be shown, using either parameters or fetching from chiffres
    @exercice_budgetaire = set_exercice_budgetaire_chiffres(params[:paramId], params[:exercice_budgetaire], @chiffres)
    # Get only the chiffres for the established "exercice_budgetaire", default to an empty array if none found
    @chiffres_exercice_budgetaire = @chiffres.where(exercice_budgetaire: @exercice_budgetaire).order(created_at: :asc) || []
    # Show a default "chiffre" based on the given parameters or the established "exercice_budgetaire"
    @chiffre_default = set_default_chiffre(params[:paramId], @exercice_budgetaire, @chiffres)
    # If a paramId is given and it doesn't match the organism's id linked to the default chiffre, redirect to the organism's chiffres index page
    redirect_to organisme_chiffres_path(@organisme) and return if params[:paramId] && @chiffre_default&.organisme_id != @organisme.id

    # Prepare the chiffres data for export
    @chiffres_export = set_export_chiffres(@chiffres)
    filename = "Budgets #{@organisme.nom}.xlsx"
    respond_to do |format|
      format.html
      format.xlsx { headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" }
    end
  end

  def show_dates
    @est_editeur = current_user == @organisme.controleur
    @chiffres = @organisme.chiffres
    @exercice_budgetaire = params[:exercice_budgetaire] && [2019, 2020, 2021, 2022, 2023, 2024, 2025].include?(params[:exercice_budgetaire].to_i) ? params[:exercice_budgetaire].to_i : Date.today.year
    @chiffres_exercice_budgetaire = @chiffres.where(exercice_budgetaire: @exercice_budgetaire).order(created_at: :asc) || []
    @chiffre_default = set_default_chiffre(nil, @exercice_budgetaire, @chiffres)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('tabs', partial: 'chiffres/tabs')
        ]
      end
    end
  end

  def new
    @chiffre = Chiffre.new
    @organismes = current_user.controleur_organismes.where(statut: 'valide', etat: 'Actif').order(nom: :asc)
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
    redirect_unless_can_edit

    @chiffre_existant = Chiffre.where(organisme_id: @organisme.id,
                                      exercice_budgetaire: params[:chiffre][:exercice_budgetaire],
                                      type_budget: params[:chiffre][:type_budget])
    if !@chiffre_existant.empty? && params[:chiffre][:type_budget] != 'Budget rectificatif'
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new_content', partial: 'chiffres/form_error', locals: { organisme: @organisme, chiffre: @chiffre_existant.first })
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
    redirect_to organisme_chiffres_path(@organisme) unless @chiffre.statut != 'valide' || params[:step]
    @steps = @chiffre.comptabilite_budgetaire == true ? 6 : 5
  end

  def update
    @steps = @chiffre.comptabilite_budgetaire == true ? 6 : 5
    @message = @chiffre.statut == 'valide' ? 'maj chiffres' : 'creation chiffres'
    if params[:chiffre][:statut] && params[:chiffre][:statut] != 'valide'
      @step = params[:chiffre][:statut].to_i + 1
      # pour garder dernière étape sauvegardee si retour en arrière
      params[:chiffre][:statut] = @chiffre.statut.to_i > params[:chiffre][:statut].to_i ? @chiffre.statut : params[:chiffre][:statut]
    end
    @chiffre.update(chiffre_params)

    @message = ' ' if @chiffre.statut != 'valide'
    redirect_path = @chiffre.statut == 'valide' ? organisme_chiffres_path(@organisme, paramId: @chiffre.id) : edit_chiffre_path(@chiffre, step: @step)
    redirect_to redirect_path, flash: { notice: @message }

  end

  def update_phase
    @can_edit = @organisme && current_user == @organisme.controleur
    redirect_to root_path and return unless @can_edit && params[:phase]

    @est_editeur = current_user == @organisme.controleur
    if params[:phase] == 'Budget non approuvé'
      exercice = @chiffre.exercice_budgetaire
      @chiffre.destroy
      redirect_to organisme_chiffres_path(@organisme, exercice_budgetaire: exercice)
    else
      @chiffre.update(phase: params[:phase])
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("content_phase-#{@chiffre.id}", partial: 'chiffres/content_phase', locals: { chiffre: @chiffre })
          ]
        end
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@organisme.nom}_#{@chiffre.type_budget}_#{@chiffre.exercice_budgetaire}",
               template: "chiffres/show",
               layout: 'pdf',
               disposition: 'inline',
               encoding: 'UTF-8'
      end
    end
  end

  def historique
    chiffres_all = select_chiffres
    @q = chiffres_all.ransack(params[:q])
    @chiffres = @q.result.includes(:organisme, :user)
    @pagy, @chiffres_page = pagy(@chiffres)
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def budgets
    extended_family_organisms = fetch_extended_family_organisms
    chiffres_user = Chiffre.where(statut: 'valide').where(organisme_id: extended_family_organisms.pluck(:id)).order(updated_at: :desc)
    @q_params = q_params
    @q = chiffres_user.ransack(params[:q])
    @chiffres = @q.result.includes(:organisme, :user)
    @pagy, @chiffres_page = pagy(@chiffres)
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def destroy
    exercice = @chiffre.exercice_budgetaire
    @chiffre&.destroy
    redirect_to organisme_chiffres_path(@organisme, exercice_budgetaire: exercice), flash: { notice: 'suppression' }
  end

  def open_phase
    modal_id = "modal-#{@chiffre.id.to_s}"
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update(modal_id, partial: 'chiffres/form_phase', locals: { chiffre: @chiffre })
        ]
      end
    end
  end

  def suivi_remplissage
    # filtres
    @q_params = q_params
    @famille = params.dig(:q, :organisme_famille_eq)
    @exercice = params.dig(:q, :exercice_budgetaire_eq) || 2025
    # Récupérer les organismes qui peuvent avoir des budgets pour l'année sélectionnée et la famille sélectionnée
    organisms_actifs = fetch_organisms_actifs(@exercice.to_i, @famille)
    # Récupérer la liste des contrôleurs de ces organismes
    controleurs_id = organisms_actifs.pluck(:controleur_id)
    @controleurs = User.includes(:chiffres, :controleur_organismes).where(id: controleurs_id, statut: ['Controleur'])
                       .order(nom: :asc)
    # récupérer les chiffres des organismes possibles et affiner en fonction des filtres choisis
    @organisms_id = organisms_actifs.pluck(:id)
    @q = Chiffre.where(statut: 'valide', organisme_id: @organisms_id).ransack(params[:q])
    @chiffres = @q.result.includes(:user)
    # afficher les graphes avec répartitions des examens sur les chiffres
    @chiffres_bi = calculate_chiffres_budget_exercice(@chiffres, @organisms_id, @exercice, 'Budget initial')
    @chiffres_cf = calculate_chiffres_budget_exercice(@chiffres, @organisms_id, @exercice, 'Compte financier')
    @pagy, @controleurs_page = pagy(@controleurs)
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def restitutions
    @chiffres = @organisme.chiffres&.where(statut: 'valide', type_budget: ['Budget initial', 'Compte financier'])&.order(Arel.sql(" exercice_budgetaire ASC, CASE
      WHEN type_budget = 'Budget initial' THEN 1
      WHEN type_budget = 'Budget rectificatif' THEN 2
      ELSE 2
    END, created_at ASC"))
    @grouped_chiffres_by_exercice = @chiffres.group_by(&:exercice_budgetaire).transform_values do |chiffres|
      chiffres.map { |chiffre| [chiffre.type_budget, chiffre.tresorerie_finale, chiffre.jours_fonctionnement_tresorerie, chiffre.emplois_total, chiffre.comptabilite_budgetaire ? chiffre.emplois_depenses_personnel : chiffre.emplois_charges_personnel, chiffre.emplois_charges_personnel, chiffre.charges_fonctionnement, chiffre.charges_intervention, chiffre.credits_cp_fonctionnement, chiffre.credits_cp_intervention, chiffre.credits_cp_investissement, chiffre.recettes_globalisees, chiffre.recettes_flechees, chiffre.produits_subventions_etat, chiffre.produits_fiscalite_affectee, chiffre.produits_subventions_autres, chiffre.produits_autres, chiffre.variation_bfr, chiffre.credits_restes_a_payer, chiffre.tresorerie_finale_flechee, chiffre.tresorerie_finale_non_flechee ] }.compact
    end
    @series = @grouped_chiffres_by_exercice.transform_values(&:last)
    exercices = @chiffres.map(&:exercice_budgetaire)
    first_exercice = exercices.min && exercices.min < 2022 ? exercices.min : 2022
    last_exercice = exercices.max && exercices.max > 2025 ? exercices.max : 2025

    @abscisses = (first_exercice..last_exercice).map(&:to_s) if first_exercice && last_exercice
    @abscisses_bis = @series.map { |k, v| "#{v.first} #{k}" }
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

  def select_chiffres
    if @statut_user == 'Controleur'
      current_user.chiffres.includes(:organisme).order(created_at: :desc)
    else
      Chiffre.all.includes(:organisme).order(created_at: :desc)
    end
  end

  def find_chiffre_and_organisme
    @chiffre = Chiffre.find(params[:id])
    @organisme = @chiffre.organisme
  end

  def redirect_unless_can_edit
    redirect_to root_path unless @organisme && current_user == @organisme.controleur
  end

  def fetch_extended_family_organisms
    organisms = Organisme.where(statut: 'valide', etat: 'Actif').includes(:controleur, :bureau, :operateur)
    if @statut_user == 'Controleur'
      organisms = organisms.where('controleur_id = :user_id OR famille IN (:familles)', user_id: current_user.id, familles: @familles)
    end
    organisms
  end

  def fetch_organisms_actifs(exercice, famille)
    organisms = Organisme.where(statut: 'valide', presence_controle: true, gbcp_1: true)
                         .where('etat = ? AND (date_creation IS NULL OR date_creation <= ?) OR (etat = ? AND date_dissolution > ?)', 'Actif', Date.new(exercice,12,31), 'Inactif', Date.new(exercice,1,1))
                         .where.not(controleur_id: User.first.id)
    if @statut_user == 'Controleur'
      organisms = organisms.where('controleur_id = :user_id OR famille IN (:familles)', user_id: current_user.id, familles: @familles)
    end
    organisms = organisms.where(famille: famille) if famille && !famille.empty?
    organisms
  end

  def redirect_unless_access
    is_controleur_or_famille = current_user == @organisme.controleur || @familles&.include?(@organisme.famille)
    condition_access = @statut_user == 'Bureau Sectoriel' || @statut_user == '2B2O' || is_controleur_or_famille
    redirect_to root_path and return unless condition_access
  end

  def set_exercice_budgetaire_chiffres(params_id, params_exercice_budgetaire, chiffres)
    if params_id
      Chiffre.find(params_id.to_i)&.exercice_budgetaire
    elsif params_exercice_budgetaire && [2019, 2020, 2021, 2022, 2023, 2024, 2025].include?(params_exercice_budgetaire.to_i)
      params_exercice_budgetaire.to_i
    else
      chiffres&.first&.exercice_budgetaire || Date.today.year
    end
  end

  def set_default_chiffre(params_id, date, chiffres)
    params_id ? Chiffre.find(params_id.to_i) : chiffres&.where(exercice_budgetaire: date)&.order(Arel.sql("CASE
      WHEN type_budget = 'Compte financier' THEN 1
      WHEN type_budget = 'Budget rectificatif' THEN 2
      ELSE 3
    END, created_at DESC"))&.first
  end

  def set_export_chiffres(chiffres)
    chiffres.where(statut: 'valide').order(Arel.sql(" exercice_budgetaire DESC, CASE
      WHEN type_budget = 'Compte financier' THEN 1
      WHEN type_budget = 'Budget rectificatif' THEN 2
      ELSE 3
    END, created_at DESC"))
  end

  def q_params
    if params[:q].present?
      params.require(:q).permit(:organisme_nom_or_organisme_acronyme_contains, :organisme_famille_eq, :exercice_budgetaire_eq, :user_nom_in_insensitive => [], :organisme_famille_in => [],
                                :exercice_budgetaire_in => [], :type_budget_in => [], :phase_in => [],
                                :comptabilite_budgetaire_in => [], :operateur_in => [], :risque_insolvabilite_in => [], :famille_in => [])
    else
      {}
    end
  end

  def calculate_chiffres_budget_exercice(chiffres, organismes, exercice_budgetaire, type_budget)
    chiffres_budget = []
    risques = ["Situation saine", "Situation saine a priori mais à surveiller", 'Risque d’insoutenabilité à moyen terme', 'Risque d’insoutenabilité élevé']
    chiffres_selected = chiffres.where(exercice_budgetaire: exercice_budgetaire, type_budget: type_budget).group_by(&:risque_insolvabilite)
    risques.each do |risque|
      chiffres_budget << (chiffres_selected[risque] || []).count
    end
    chiffres_empty = organismes.count - chiffres_selected.values.flatten.count
    chiffres_budget << chiffres_empty
    chiffres_budget
  end

end
