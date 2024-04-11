# frozen_string_literal: true

# Controller Pages Chiffres
class ChiffresController < ApplicationController
  before_action :authenticate_user!
  before_action :find_organisme, only: %i[index show_dates]
  before_action :set_famille, only: %i[index show_dates]
  before_action :find_chiffre_and_organisme, only: %i[edit update update_phase destroy open_phase]

  # page des chiffres clés de l'organisme
  def index
    @est_editeur = current_user == @organisme.controleur
    est_bureau_ou_famille = @statut_user == 'Bureau Sectoriel' || @familles&.include?(@organisme.famille)
    redirect_to root_path and return unless @statut_user == '2B2O' || @est_editeur || est_bureau_ou_famille

    @chiffres = @organisme.chiffres.order(exercice_budgetaire: :desc)
    if params[:paramId]
      @chiffre_param = Chiffre.where(id: params[:paramId].to_i).first
      redirect_to organisme_chiffres_path(@organisme) and return unless @chiffre_param && @chiffre_param.organisme_id == @organisme.id

      @date = @chiffre_param.exercice_budgetaire
    else
      @date_dernier_chiffre = @chiffres.first&.exercice_budgetaire || Date.today.year
      @date = params[:exercice_budgetaire] && [2022, 2023, 2024].include?(params[:exercice_budgetaire].to_i) ? params[:exercice_budgetaire].to_i : @date_dernier_chiffre
    end

    liste_budgets(@date, @chiffres)
    @bi_selected = [@compte_financier, @budgets_rectificatifs].flatten.empty? || (params[:paramId] && params[:paramId].to_i == @budget_initial.first&.id)
    @cf_selected = !@compte_financier.empty? && params[:paramId].nil? || params[:paramId].to_i == @compte_financier.first&.id
    @chiffres_export = @chiffres.where(statut: 'valide').order(Arel.sql(" exercice_budgetaire DESC, CASE
      WHEN type_budget = 'Compte financier' THEN 1
      WHEN type_budget = 'Budget rectificatif' THEN 2
      ELSE 3
    END, created_at DESC"))
    filename = "chiffres_#{@organisme.nom}.xlsx"
    respond_to do |format|
      format.html
      format.xlsx { headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" }
    end
  end

  def show_dates
    @est_editeur = current_user == @organisme.controleur
    @chiffres = @organisme.chiffres
    @date = params[:exercice_budgetaire] && [2022, 2023, 2024].include?(params[:exercice_budgetaire].to_i) ? params[:exercice_budgetaire].to_i : Date.today.year
    liste_budgets(@date, @chiffres)
    @bi_selected = [@compte_financier, @budgets_rectificatifs].flatten.empty?
    @cf_selected = !@compte_financier.empty?
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('tabs', partial: 'chiffres/tabs')
        ]
      end
    end
  end

  def new
    redirect_to root_path and return unless @statut_user == 'Controleur'

    @chiffre = Chiffre.new
    @organismes = current_user.controleur_organismes.where(statut: 'valide', etat: 'Actif')
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
    redirect_unless_can_edit
    redirect_to organisme_chiffres_path(@organisme) unless @chiffre.statut != 'valide' || params[:step]
    @steps = @chiffre.comptabilite_budgetaire == true ? 6 : 5
    @numero_br = @chiffre.type_budget == 'Budget rectificatif' ? @organisme.chiffres.where(exercice_budgetaire: @chiffre.exercice_budgetaire, type_budget: 'Budget rectificatif').order(created_at: :asc).pluck(:id).index(@chiffre.id)+1 : ""
  end

  def update
    redirect_unless_can_edit
    @steps = @chiffre.comptabilite_budgetaire == true ? 6 : 5
    @message = @chiffre.statut == 'valide' ? 'maj chiffres' : 'creation chiffres'
    if params[:chiffre][:statut] && params[:chiffre][:statut] != 'valide'
      @step = params[:chiffre][:statut].to_i + 1
      # pour garder dernière étape sauvegardee si retour en arrière
      params[:chiffre][:statut] = @chiffre.statut.to_i > params[:chiffre][:statut].to_i ? @chiffre.statut : params[:chiffre][:statut]
    end
    @chiffre.update(chiffre_params)
    updateRisque(@chiffre)

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

  def historique
    select_chiffres
    @exercices = @chiffres.pluck(:exercice_budgetaire).uniq.sort
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def filtre_chiffres
    select_chiffres
    @exercices = @chiffres.pluck(:exercice_budgetaire).uniq.sort
    @chiffres = @chiffres.select { |el| params[:budgets].include?(el.type_budget) } if params[:budgets] && params[:budgets].length != 3
    @chiffres = @chiffres.select { |el| params[:phases].include?(el.phase) } if params[:phases] && params[:phases].length != 4
    @chiffres = @chiffres.select { |el| params[:exercices].include?(el.exercice_budgetaire.to_s) } if params[:exercices] && params[:exercices].length != @exercices.length
    if params[:risque_insolvabilites]&.include?('Brouillon')
      @chiffres = @chiffres.select { |el| params[:risque_insolvabilites].include?(el.risque_insolvabilite) || el.statut != 'valide'}
    else
      @chiffres = @chiffres.select { |el| params[:risque_insolvabilites].include?(el.risque_insolvabilite) && el.statut == 'valide'} if params[:risque_insolvabilites] && params[:risque_insolvabilites].length != 5
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

  def suivi
    liste_organisme
    @liste_organismes = @organismes.pluck(:id, :nom, :acronyme).sort_by { |e| normalize_name(e[1]) }
    liste_chiffres_organismes = @organismes.joins(:chiffres).pluck(:id,"chiffres.type_budget AS chiffre_budget","chiffres.exercice_budgetaire AS chiffre_exercice", "chiffres.statut AS chiffre_statut", "chiffres.risque_insolvabilite AS chiffre_risque_insolvabilite", "chiffres.created_at AS chiffre_date")
    @liste_chiffres_organismes = liste_chiffres(liste_chiffres_organismes)
  end

  def filtre_suivi
    liste_organisme
    @liste_organismes = @organismes.pluck(:id, :nom, :acronyme).sort_by { |e| normalize_name(e[1]) }
    liste_chiffres_organismes = @organismes.joins(:chiffres).pluck(:id,"chiffres.type_budget AS chiffre_budget","chiffres.exercice_budgetaire AS chiffre_exercice", "chiffres.statut AS chiffre_statut", "chiffres.risque_insolvabilite AS chiffre_risque_insolvabilite", "chiffres.created_at AS chiffre_date")
    @liste_chiffres_organismes = liste_chiffres(liste_chiffres_organismes)
    liste_organismes_filter_id = []
    [[params[:budget_bis], 'Budget initial'], [params[:budget_brs], 'Budget rectificatif'], [params[:budget_cfs], 'Compte financier']].each do |param|
      if param[0]&.include?('Brouillon')
        @liste_chiffres_brouillon_id = @liste_chiffres_organismes.select { |el| param[1] == el[1] && el[2] == params[:exercice].to_i && el[3] != 'valide' }.map { |el| el[0] }.uniq
        liste_organismes_filter_id += @liste_chiffres_brouillon_id
      end
      if param[0]&.include?('Non renseigné') || param[0]&.include?('Aucun')
        id_orga_chiffres = @liste_chiffres_organismes.select { |el| param[1] == el[1] && el[2] == params[:exercice].to_i}.map { |el| el[0] }.uniq
        @liste_organismes_nr_id = @liste_organismes.reject { |el| id_orga_chiffres.include?(el[0]) }.map { |el| el[0] }.uniq
        liste_organismes_filter_id += @liste_organismes_nr_id
      end
      if param[0] && param[0].length != 6
        @liste_chiffres_risque_id = @liste_chiffres_organismes.select { |el| param[1] == el[1] && el[2] == params[:exercice].to_i && param[0].include?(el[4]) && el[3] == 'valide' }.map { |el| el[0] }.uniq
        liste_organismes_filter_id += @liste_chiffres_risque_id
      end
    end
    if params[:budget_bis].length != 6 || params[:budget_brs].length != 6 || params[:budget_cfs].length != 6
      @liste_organismes = @liste_organismes.select { |el| liste_organismes_filter_id.include?(el[0]) }
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("suivi_table_body#{params[:exercice].to_s}", partial: 'chiffres/suivi_table_body', locals: { exercice: params[:exercice].to_i, liste_organismes: @liste_organismes, liste_chiffres_organismes: @liste_chiffres_organismes }),
          turbo_stream.update("total_table#{params[:exercice].to_s}", partial: 'chiffres/suivi_table_total', locals: { total: @liste_organismes.length })
        ]
      end
    end
  end

  def destroy
    redirect_unless_can_edit

    exercice = @chiffre.exercice_budgetaire
    @chiffre&.destroy
    message = 'suppression'
    redirect_to organisme_chiffres_path(@organisme, exercice_budgetaire: exercice), flash: { notice: message }
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
    redirect_to root_path and return unless @statut_user == '2B2O'

    @users = User.where(statut: ['Controleur'])
    hash_organismes_users = Organisme.group(:controleur_id, :etat, :id).count
    hash_chiffres_users = Chiffre.group(:user_id, :statut, :exercice_budgetaire, :type_budget, :organisme_id).count
    @array_remplissage_user = []

    @users.each do |user|
      array_user = [user.nom,
                    hash_organismes_users.select { |key, _value| key[0] == user.id && key.include?('Actif') }.values.sum,
                    hash_chiffres_users.select { |key, _value| key[0] == user.id && key.include?('valide') }.values.sum,
                    hash_chiffres_users.select { |key, _value| key[0] == user.id && key.include?('valide') && key[2] == 2024 && key[3] == 'Budget initial' }.values.sum,
                    hash_chiffres_users.select { |key, _value| key[0] == user.id && key.include?('valide') && key[2] == 2023 && key[3] == 'Compte financier' }.values.sum]
      array_user << (array_user[1].zero? ? 100 : (array_user[2].to_f / array_user[1]) * 100).round
      array_user << (array_user[1].zero? ? 100 : (array_user[3].to_f / array_user[1]) * 100).round
      array_user << (array_user[1].zero? ? 100 : (array_user[4].to_f / array_user[1]) * 100).round
      @array_remplissage_user << array_user
    end

    @array_remplissage_user = @array_remplissage_user.sort_by { |e| -e[4] }

    respond_to do |format|
      format.html
      format.xlsx
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
    chiffres.order(created_at: :asc).select { |el| el.type_budget == type_budget && el.exercice_budgetaire == exercice_budgetaire }
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

  def normalize_name(name)
    # Supprime les accents et met le texte en minuscules
    I18n.transliterate(name).downcase
  end

  def set_famille
    if @statut_user == 'Controleur'
      @familles = current_user.controleur_organismes.pluck(:famille).uniq.reject { |element| element == 'Aucune' }
      @familles += ['Universités'] if current_user.nom == 'CBCM MEN-MESRI'
    elsif @statut_user == 'Bureau Sectoriel'
      @familles = current_user.bureau_organismes.pluck(:famille).uniq.reject { |element| element == 'Aucune' }
    end
  end

  def find_chiffre_and_organisme
    @chiffre = Chiffre.find(params[:id])
    @organisme = @chiffre.organisme
  end

  def redirect_unless_can_edit
    return redirect_to(root_path) unless @organisme && current_user == @organisme.controleur
  end

  def liste_organisme
    @organismes = case @statut_user
                        when '2B2O'
                          Organisme.where(statut: 'valide', etat: 'Actif')
                        when 'Controleur'
                          current_user.controleur_organismes.where(statut: 'valide', etat: 'Actif')
                        when 'Bureau Sectoriel'
                          current_user.bureau_organismes.where(statut: 'valide', etat: 'Actif')
                        end
  end

  def updateRisque(chiffre)
    if chiffre.comptabilite_budgetaire == true && chiffre.statut == 'valide'
      @solde = chiffre.credits_financements_etat_autres + chiffre.credits_fiscalite_affectee + chiffre.credits_financements_publics_autres + chiffre.credits_recettes_propres_globalisees + chiffre.credits_financements_etat_fleches + chiffre.credits_financements_publics_fleches + chiffre.credits_recettes_propres_flechees - chiffre.credits_cp_total
      @solde = chiffre.operateur == true ? @solde + chiffre.credits_subvention_sp + chiffre.credits_subvention_investissement_globalisee + chiffre.credits_subvention_investissement_flechee : @solde
    else
      @solde = nil
    end
    chiffre.risque_insolvabilite = calculateRisque(@solde, chiffre.tresorerie_variation, chiffre.fonds_roulement_variation,chiffre.fonds_roulement_variation-chiffre.tresorerie_variation ) if chiffre.statut == 'valide'
    chiffre.save
  end

  def calculateRisque(solde_budgetaire, tresorerie_variation,fonds_roulement_variation, variation_besoin_fr)
    if !solde_budgetaire.nil?
      if (solde_budgetaire >= 0 && tresorerie_variation >= 0 && fonds_roulement_variation >= 0) || (solde_budgetaire >= 0 && tresorerie_variation < 0 && fonds_roulement_variation >= 0 && variation_besoin_fr >= 0)
        'Situation saine'
      elsif (solde_budgetaire >= 0 && tresorerie_variation >= 0 && fonds_roulement_variation < 0 && variation_besoin_fr < 0) || (solde_budgetaire >= 0 && tresorerie_variation < 0 && fonds_roulement_variation < 0 && variation_besoin_fr < 0) || (solde_budgetaire < 0 && tresorerie_variation >= 0 && fonds_roulement_variation >= 0 && variation_besoin_fr >= 0) || (solde_budgetaire < 0 && tresorerie_variation < 0 && fonds_roulement_variation >= 0 && variation_besoin_fr >= 0)
        'Situation saine a priori mais à surveiller'
      elsif (solde_budgetaire >= 0 && tresorerie_variation < 0 && fonds_roulement_variation < 0 && variation_besoin_fr >= 0) || (solde_budgetaire < 0 && tresorerie_variation >= 0 && fonds_roulement_variation >= 0 && variation_besoin_fr < 0)
        "Risque d’insoutenabilité à moyen terme"
      elsif (solde_budgetaire < 0 && tresorerie_variation >= 0 && fonds_roulement_variation < 0 && variation_besoin_fr < 0) || (solde_budgetaire < 0 && tresorerie_variation < 0 && fonds_roulement_variation < 0 && variation_besoin_fr >= 0) || (solde_budgetaire < 0 && tresorerie_variation < 0 && fonds_roulement_variation < 0 && variation_besoin_fr < 0)
        "Risque d’insoutenabilité élevé"
      end
    else
      if tresorerie_variation >= 0 && fonds_roulement_variation >= 0
        'Situation saine'
      elsif (tresorerie_variation < 0 && fonds_roulement_variation >= 0) || (tresorerie_variation >= 0 && fonds_roulement_variation < 0)
        'Situation saine a priori mais à surveiller'
      elsif tresorerie_variation < 0 && fonds_roulement_variation < 0
        "Risque d’insoutenabilité élevé"
      end
    end
  end

  def liste_chiffres(liste_chiffres_organismes)
    # Utilisation d'un hash pour regrouper les sous-tableaux par les deux premiers éléments
    grouped_hash = liste_chiffres_organismes.group_by { |subarray| [subarray[0], subarray[1], subarray[2]] }

    # Initialisation d'un nouveau tableau résultant
    resultat = []

    # Itération sur les valeurs du hash
    grouped_hash.values.each do |subarrays|
      # Trier les sous-tableaux par la date en utilisant le dernier élément de chaque sous-tableau
      sous_tableau_recent = subarrays.max_by { |subarray| subarray.last }
      # Ajouter le sous-tableau avec la date la plus récente au résultat
      resultat << sous_tableau_recent
    end
    resultat
  end

end
