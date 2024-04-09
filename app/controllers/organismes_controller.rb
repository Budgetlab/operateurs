# frozen_string_literal: true

# Controller Pages organismes
require 'google/cloud/storage'

class OrganismesController < ApplicationController
  include Authentication
  before_action :authenticate_user!
  before_action :redirect_unless_admin, only: %i[new create destroy]
  before_action :fetch_list_name_filter, only: :index
  before_action :set_organisme, only: %i[show edit update destroy]
  before_action :redirect_unless_access, only: :show
  before_action :redirect_unless_editor, only: %i[edit update]
  def index
    # Fetch all organisms relevant to user's permissions, including those in extended families
    extended_family_organisms = fetch_extended_family_organisms
    @q_params = q_params
    q_params_send = params[:q]
    if q_params_send
      if q_params_send[:operateur_operateur_n_null] == 'true' && q_params[:operateur_operateur_n_in]&.include?('true')
        value_resset_all = true
        q_params_send.delete(:operateur_operateur_n_null)
        q_params_send.delete(:operateur_operateur_n_in)
      elsif q_params_send[:operateur_operateur_n_null] == 'true'
        value_resset_operateur_n = true
        q_params_send.delete(:operateur_operateur_n_null)
        extended_family_organisms_not_operateur = extended_family_organisms.where(operateurs: { operateur_n: nil} )
        extended_family_organisms_operateur_false = extended_family_organisms.where(operateurs: { operateur_n: false} )
        extended_family_organisms = extended_family_organisms_not_operateur.or(extended_family_organisms_operateur_false)
      end
    end
    @q = extended_family_organisms.ransack(q_params_send)
    @organisms_for_results = @q.result.includes(:bureau, :controleur)
    if value_resset_all
      q_params_send[:operateur_operateur_n_null] = 'true'
      q_params_send[:operateur_operateur_n_in] = ["true"]
    elsif value_resset_operateur_n
      q_params_send[:operateur_operateur_n_null] = 'true'
    end
    respond_to do |format|
      format.html do
        @pagy, @organisms_page = pagy(@organisms_for_results)
      end
      format.any do
        headers['Content-Disposition'] = 'attachment; filename="Liste_organismes.xlsx"'
        render xlsx: 'index', filename: 'Liste_organismes.xlsx', disposition: 'attachment'
      end
    end
  end

  def search_organismes
    extended_family_organisms = fetch_extended_family_organisms
    @q = extended_family_organisms.ransack(params[:organisme_search])
    @organisms_for_results = @q.result(distinct: true)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('search_results', partial: 'organismes/search_organismes', locals: {organisms_for_results: @organisms_for_results})
        ]
      end
    end
  end

  def show
    @admin = @statut_user == '2B2O' || (current_user == @organisme.controleur && @organisme.etat != 'Inactif')
    @est_valide = @organisme.statut == 'valide'
    @organisme_ministeres = @organisme.organisme_ministeres.includes(:ministere)
    @operateur = Operateur.includes(:mission, :programme, :operateur_programmes).find_by(organisme_id: @organisme.id)
    @operateur_programmes = @operateur.operateur_programmes.includes(:programme) if @operateur
    modifications = @organisme.modifications.includes(:user).order(updated_at: :desc)
    @modifications_valides_organisme = modifications.select { |modification| modification.statut == 'validée' }
    @modifications_rejetees_organisme = modifications.select { |modification| modification.statut == 'refusée' }
    @modifications_attente_organisme = modifications.select { |modification| modification.statut == 'En attente' }
    @organisme_destinations = OrganismeRattachement.where(organisme_destination_id: @organisme.id)
    @chiffre = @organisme.chiffres.where(statut: 'valide').order(Arel.sql(" exercice_budgetaire DESC, CASE
      WHEN type_budget = 'Compte financier' THEN 1
      WHEN type_budget = 'Budget rectificatif' THEN 2
      ELSE 3
    END, created_at DESC")).first
    filename = 'fiche_organisme.xlsx'
    respond_to do |format|
      format.html
      format.any { headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" }
    end
  end

  def new
    @organisme = Organisme.new
    @bureaux = User.where(statut: 'Bureau Sectoriel').order(nom: :asc)
    @organismes = Organisme.where.not(id: @organisme.id).sort_by { |organisme| normalize_name(organisme.nom) }.pluck(:nom, :id, :siren, :etat, :acronyme)
    @noms_organismes = @organismes.map { |el| el[0] }
    @siren_organismes = @organismes.map { |el| el[2] }.compact
    @organismes_rattachement = @organismes.select { |el| el[3] == 'Actif' || el[3] == 'En cours de création' }
    @liste_organisme_rattachement = @organisme.organisme_rattachements.pluck(:organisme_destination_id)
  end

  def create
    organismes_to_link = params[:organisme].delete(:organismes)
    @organisme = Organisme.new(organisme_params)
    @organisme.controleur = current_user if @organisme.controleur_id.nil?
    if @organisme.save
      update_organisme_rattachements(organismes_to_link)
      redirect_to edit_organisme_path(@organisme.id)
    else
      render :new
    end
  end

  def edit
    redirect_to edit_organisme_path(@organisme) if params[:step] && @organisme.statut != 'valide' && params[:step].to_i > @organisme.statut.to_i + 1

    if params[:step].to_i == 1
      @bureaux = User.where(statut: 'Bureau Sectoriel').order(nom: :asc)
      @organismes = Organisme.where.not(id: @organisme.id).sort_by { |organisme| normalize_name(organisme.nom) }.pluck(:nom, :id, :siren, :etat, :acronyme)
      @noms_organismes = @organismes.map { |el| el[0] }
      @siren_organismes = @organismes.map { |el| el[2] }.compact
      @organismes_rattachement = @organismes.select { |el| el[3] == 'Actif' || el[3] == 'En cours de création' }
      @liste_organisme_rattachement = @organisme.organisme_rattachements.pluck(:organisme_destination_id)
    end
    @controleurs = User.where(statut: 'Controleur').order(nom: :asc)
    @ministeres = Ministere.order(nom: :asc)
    @liste_ministere = @organisme.organisme_ministeres.pluck(:ministere_id)
  end

  def update
    organismes_to_link = params[:organisme].delete(:organismes)
    ministeres_to_link = params[:organisme].delete(:ministeres)
    reset_values(%i[date_dissolution effet_dissolution]) if params[:organisme][:etat]
    reset_values(%i[nature_controle texte_soumission_controle autorite_controle texte_reglementaire_controle arrete_controle document_controle_present document_controle_lien document_controle_date arrete_nomination]) if params[:organisme][:presence_controle]
    reset_values([:admin_db_fonction]) if params[:organisme][:admin_db_present]
    reset_values([:delegation_approbation]) if params[:organisme][:tutelle_financiere]
    if @organisme.statut == 'valide'
      modifications = generate_modifications(ministeres_to_link)
      create_modifications(modifications)
    end
    message = @organisme.statut == 'valide' ? 'maj' : 'creation'
    message = 'maj controleur' if @statut_user == 'Controleur'
    if @statut_user == '2B2O'
      if params[:organisme][:statut] && params[:organisme][:statut] != 'valide'
        step = params[:organisme][:statut].to_i + 1
        params[:organisme][:statut] = @organisme.statut.to_i > params[:organisme][:statut].to_i ? @organisme.statut : params[:organisme][:statut] # pour garder étape si retour en arrière
      end
      @organisme.update(organisme_params)
      update_organisme_rattachements(organismes_to_link)
      update_organisme_ministeres(ministeres_to_link)
      update_modifications_attente(@organisme)
      update_gip(@organisme) if @organisme.nature == 'GIP'
    end
    redirect_path = @organisme.statut == 'valide' ? @organisme : edit_organisme_path(@organisme, step: step)
    redirect_to redirect_path, flash: { notice: message }
  end

  def destroy
    @organisme&.destroy
    redirect_to organismes_path
  end

  private

  def organisme_params
    params.require(:organisme).permit(:statut, :etat, :nom, :siren, :acronyme, :date_creation, :famille, :nature,
                                      :date_previsionnelle_dissolution, :date_dissolution, :effet_dissolution,
                                      :bureau_id, :texte_institutif, :commentaire, :gbcp_1, :agent_comptable_present,
                                      :degre_gbcp, :gbcp_3, :comptabilite_budgetaire, :presence_controle, :controleur_id,
                                      :nature_controle, :texte_soumission_controle, :autorite_controle,
                                      :texte_reglementaire_controle, :arrete_controle, :document_controle_present,
                                      :document_controle_lien, :document_controle_date, :arrete_nomination,
                                      :tutelle_financiere, :delegation_approbation, :autorite_approbation, :ministere_id,
                                      :admin_db_present, :admin_db_fonction, :admin_preca, :controleur_preca,
                                      :controleur_ca, :comite_audit, :apu, :ciassp_n, :ciassp_n1, :odac_n, :odac_n1,
                                      :odal_n, :odal_n1, :arrete_interdiction_odac)
  end

  def reset_values(param_names)
    param_names.each do |param|
      params[:organisme][param.to_sym] = params[:organisme].fetch(param.to_sym, nil)
    end
  end

  def set_organisme
    @organisme = Organisme.includes(:ministere, :bureau, :controleur, :organisme_ministeres).find(params[:id])
  end

  def redirect_unless_access
    is_controleur_or_famille = current_user == @organisme.controleur || @familles&.include?(@organisme.famille)
    condition_access = @statut_user == 'Bureau Sectoriel' || @statut_user == '2B2O' || is_controleur_or_famille
    redirect_to root_path and return unless condition_access
  end

  def redirect_unless_editor
    is_controleur_editor = current_user == @organisme.controleur && @organisme.statut == 'valide' && @organisme.etat != 'Inactif'
    redirect_to root_path and return unless @statut_user == '2B2O' || is_controleur_editor
  end

  def fetch_extended_family_organisms
    organisms = Organisme.all.includes(:controleur, :bureau, :operateur)
    case @statut_user
    when 'Controleur'
      organisms = organisms.where(statut: 'valide').where('controleur_id = :user_id OR famille IN (:familles)', user_id: current_user.id, familles: @familles)
    when 'Bureau Sectoriel'
      organisms = organisms.where(statut: 'valide')
    end
    organisms.order(:nom)
  end

  def update_organisme_rattachements(organismes_to_link)
    @organisme.organisme_rattachements.destroy_all if @organisme.etat != 'Inactif'
    if organismes_to_link && organismes_to_link.map(&:to_i).reject { |element| element.zero? } != @organisme.organisme_rattachements.pluck(:organisme_destination_id)
      @organisme.organisme_rattachements.destroy_all
      selected_organismes = organismes_to_link || [] # Récupérer les valeurs cochées
      selected_organismes.map(&:to_i).reject { |element| element.zero? }.each do |organisme_id|
        @organisme.organisme_rattachements.create(organisme_destination_id: organisme_id)
      end
    end
  end

  def update_organisme_ministeres(ministeres_to_link)
    if ministeres_to_link && ministeres_to_link.map(&:to_i).reject { |element| element.zero? } != @organisme.organisme_ministeres.pluck(:ministere_id)
      @organisme.organisme_ministeres.destroy_all
      selected_ministeres = ministeres_to_link || []
      selected_ministeres.map(&:to_i).reject { |element| element.zero? }.each do |ministere_id|
        @organisme.organisme_ministeres.create(ministere_id: ministere_id)
      end
    end
  end

  def update_modifications_attente(organisme)
    modifications_attente = organisme.modifications.where(statut: 'En attente')
    if organisme.etat == 'Inactif' && !modifications_attente.empty?
      modifications_attente.each do |modification|
        modification.update(statut: 'refusée', commentaire: 'Organisme devenu inactif')
      end
    end
  end

  def generate_modifications(ministeres_to_link)
    modifications = []
    champs_a_surveiller = %i[nom etat acronyme siren nature texte_institutif commentaire gbcp_1 gbcp_3
                           comptabilite_budgetaire nature_controle texte_soumission_controle autorite_controle
                           texte_reglementaire_controle arrete_controle document_controle_date comite_audit
                           arrete_nomination ciassp_n ciassp_n1 odal_n odal_n1 odac_n odac_n1]
    champs_texte = ['Nom', 'État', 'Acronyme', 'Siren', 'Nature juridique', 'Texte institutif', 'Commentaire', 'Partie I GBCP',
                    'Partie III GBCP', 'Comptabilité budgétaire', 'Nature contrôle', 'Texte soumission au contrôle',
                    'Autorité de contrôle', "Texte réglementaire de désignation de l'autorité de contrôle",
                    'Arrêté de contrôle', 'Date signature document contrôle ', 'Comité audit et risques',
                    'Arrêté de nomination comissaire du gouvernement', "CIASSP #{(Date.today.year).to_s}",
                    "CIASSP #{(Date.today.year - 1).to_s}", "ODAL #{(Date.today.year - 2).to_s}",
                    "ODAL #{(Date.today.year - 3).to_s}", "ODAC #{(Date.today.year - 2).to_s}",
                    "ODAC #{(Date.today.year - 3).to_s}"]
    champs_supp_controleur = %i[date_creation date_previsionnelle_dissolution agent_comptable_present
                              degre_gbcp document_controle_present document_controle_lien ministere_id
                              admin_db_present admin_db_fonction admin_preca controleur_preca controleur_ca]
    champs_supp_texte = ['Date création', 'Date prévisionnelle dissolution', 'Présence agent comptable', 'Degré GBCP',
                         'Présence document contrôle', 'Lien document contrôle', 'Ministère', 'Présence Admin DB',
                         'Fonction Admin DB', 'Présence DB préCA', 'Présence contrôleur préCA', 'Présence contrôleur CA']
    champs_a_surveiller.each_with_index do |champ, i|
      if organisme_params[champ] && organisme_params[champ].to_s != check_format(@organisme[champ]) # réucpérer que ceux qui sont dans le formulaire
        modifications << { champ: champ.to_s, nom: champs_texte[i], ancienne_valeur: check_format(@organisme[champ]), nouvelle_valeur: organisme_params[champ].to_s }
      end
    end
    if current_user.statut == 'Controleur'
      champs_supp_controleur.each_with_index do |champ, i|
        if organisme_params[champ] && organisme_params[champ].to_s != check_format(@organisme[champ])
          modifications << { champ: champ.to_s, nom: champs_supp_texte[i], ancienne_valeur: check_format(@organisme[champ]), nouvelle_valeur: organisme_params[champ].to_s }
        end
      end
      if ministeres_to_link && ministeres_to_link.map(&:to_i).reject { |element| element.zero? } != @organisme.organisme_ministeres.pluck(:ministere_id)
        nouvelle_valeur = ministeres_to_link.map(&:to_i).reject { |element| element.zero? }
        modifications << { champ: 'ministeres', nom: 'Ministère•s co-tutelle', ancienne_valeur: @organisme.organisme_ministeres.pluck(:ministere_id), nouvelle_valeur: nouvelle_valeur }
      end
    end
    modifications
  end

  def check_format(field)
    field = field.is_a?(Date) ? field.strftime('%d/%m/%Y') : field.to_s
    field
  end

  def create_modifications(modifications)
    statut = @statut_user == '2B2O' ? 'validée' : 'En attente'
    modifications.each do |modification|
      @organisme.modifications.create(
        champ: modification[:champ],
        nom: modification[:nom],
        ancienne_valeur: modification[:ancienne_valeur],
        nouvelle_valeur: modification[:nouvelle_valeur],
        user_id: current_user.id, statut: statut
      )
    end
  end

  def normalize_name(name)
    # Supprime les accents et met le texte en minuscules
    I18n.transliterate(name).downcase
  end

  def update_gip(organisme)
    organisme.update(tutelle_financiere: false, delegation_approbation: false, autorite_approbation: nil, ministere_id: nil)
    organisme.organisme_ministeres&.destroy_all
  end

  def fetch_list_name_filter
    users = User.order(:nom)
    @bs_name_list = users.select { |user| ['Bureau Sectoriel', '2B2O'].include?(user.statut) }.map(&:nom)
    @controleur_name_list = users.select { |user| ['Controleur', '2B2O'].include?(user.statut) }.map(&:nom)
    @missions_list = Mission.all.order(:nom).pluck(:nom).uniq
    @programs_list = Programme.all.order(:numero).pluck(:numero)
  end

  def q_params
    if params[:q].present?
      params.require(:q).permit(:nom_or_acronyme_contains, :operateur_operateur_n_null, :etat_in => [], :statut_not_eq => [], :famille_in => [],
                                :nature_in => [],:operateur_operateur_n_in => [], :controleur_nom_in_insensitive => [],
                                :nature_controle_in => [] ,:autorite_controle_in => [], :document_controle_present_in => [],
                                :bureau_nom_in => [], :operateur_nom_categorie_in => [], :operateur_mission_nom_in => [],
                                :operateur_programme_numero_in => [], :gbcp_1_in => [], :gbcp_3_in => [],
                                :comptabilite_budgetaire_in => [], :tutelle_financiere_in => [], :delegation_approbation_in => [],
                                :autorite_approbation_in => [], :ministere_nom_in => [],
                                :organisme_ministeres_ministere_nom_in => [], :admin_db_present_in => [], :admin_preca_in => [],
                                :controleur_preca_in => [], :controleur_ca_in => [], :comite_audit_in => [], :apu_in => [],
                                :ciassp_n_in => [], :odal_n_in => [], :odac_n_in => [], :arrete_interdiction_odac_in => [])
    else
      {}
    end
  end

end
