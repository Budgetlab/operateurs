# frozen_string_literal: true

# Controller Pages organismes
class OrganismesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_famille, only: [:show, :recherche_organismes]
  def index
    redirect_to root_path and return unless @statut_user == '2B2O' || @statut_user == 'Controleur'

    organismes = @statut_user == '2B2O' ? Organisme.all : current_user.controleur_organismes.where(statut: 'valide')
    @organismes = organismes.sort_by { |organisme| normalize_name(organisme.nom) }.pluck(:id, :nom, :statut, :etat, :acronyme)
    @organismes_actifs = @organismes.select { |el| el[2] == 'valide' && el[3] == 'Actif' }
    @organismes_inactifs = @organismes.select { |el| el[2] == 'valide' && el[3] == 'Inactif' }
    @organismes_creation = @organismes.select { |el| el[2] == 'valide' && el[3] == 'En cours de création' }
    @organismes_brouillon = @organismes.reject { |el| el[2] == 'valide' }
    @search_organismes = []
  end

  def recherche_organismes
    search = params[:search]
    @search_organismes =
      if search.blank?
        []
      elsif @statut_user == '2B2O'
        Organisme.where('unaccent(nom) ILIKE unaccent(:search) OR unaccent(acronyme) ILIKE unaccent(:search)', search: "%#{search}%")
      else
        user_relation = case @statut_user
                        when 'Controleur'
                          current_user.controleur_organismes.where(statut: 'valide').where('unaccent(nom) ILIKE unaccent(:search) OR unaccent(acronyme) ILIKE unaccent(:search)', search: "%#{search}%")
                        when 'Bureau Sectoriel'
                          current_user.bureau_organismes.where(statut: 'valide').where('unaccent(nom) ILIKE unaccent(:search) OR unaccent(acronyme) ILIKE unaccent(:search)', search: "%#{search}%")
                        else
                          []
                        end

        famille_relation = Organisme.where(famille: @familles, statut: 'valide').where('unaccent(nom) ILIKE unaccent(:search) OR unaccent(acronyme) ILIKE unaccent(:search)', search: "%#{search}%")

        user_relation.or(famille_relation)
      end
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('resultats', partial: 'organismes/recherche_organismes')
        ]
      end
    end
  end

  def organismes_ajout
    redirect_to root_path and return unless @statut_user == '2B2O'

    @organismes = Organisme.where(statut: 'valide').sort_by { |organisme| normalize_name(organisme.nom) } || []
    filename = 'liste_organismes.xlsx'
    respond_to do |format|
      format.html
      format.xlsx { headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" }
    end
  end

  def show
    @organisme = Organisme.includes(:ministere, :bureau, :controleur, :organisme_ministeres).find(params[:id])
    est_controleur = current_user == @organisme.controleur
    est_famille = @familles && @familles.include?(@organisme.famille)
    redirect_to root_path and return unless @statut_user == '2B2O' || est_controleur || est_famille

    @admin = @statut_user == '2B2O' || (est_controleur && @organisme.etat != 'Inactif')
    @est_valide = @organisme.statut == 'valide'
    @organisme_ministeres = @organisme.organisme_ministeres.includes(:ministere)
    @operateur = Operateur.includes(:mission, :programme, :operateur_programmes).find_by(organisme_id: @organisme.id)
    @operateur_programmes = @operateur.operateur_programmes.includes(:programme) if @operateur
    modifications = @organisme.modifications.includes(:user).order(created_at: :desc)
    @modifications_valides_organisme = modifications.select { |modification| modification.statut == 'validée' }
    @modifications_rejetees_organisme = modifications.select { |modification| modification.statut == 'refusée' }
    @modifications_attente_organisme = modifications.select { |modification| modification.statut == 'En attente' }
    @organisme_destinations = OrganismeRattachement.where(organisme_destination_id: @organisme.id)
    filename = 'fiche_organisme.xlsx'
    respond_to do |format|
      format.html
      format.xlsx { headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" }
    end
  end

  def new
    redirect_to root_path and return unless @statut_user == '2B2O'

    @organisme = Organisme.new
    @bureaux = User.where(statut: 'Bureau Sectoriel').order(nom: :asc)
    @organismes = Organisme.where.not(id: @organisme.id).sort_by { |organisme| normalize_name(organisme.nom) }.pluck(:nom, :id, :siren, :etat)
    @noms_organismes = @organismes.map { |el| el[0] }
    @siren_organismes = @organismes.map { |el| el[2] }.compact
    @organismes_rattachement = @organismes.select { |el| el[3] == 'Actif' || el[3] == 'En cours de création' }
    @liste_organisme_rattachement = @organisme.organisme_rattachements.pluck(:organisme_destination_id)
  end

  def create
    redirect_to root_path and return unless @statut_user == '2B2O'

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
    @organisme = Organisme.find(params[:id])
    @est_controleur = current_user == @organisme.controleur && @organisme.statut == 'valide' && @statut_user != '2B2O' && @organisme.etat != 'Inactif'
    redirect_to root_path and return unless @statut_user == '2B2O' || @est_controleur

    redirect_to edit_organisme_path(@organisme) if params[:step] && @organisme.statut != 'valide' && params[:step].to_i > @organisme.statut.to_i + 1

    if params[:step].to_i == 1
      @bureaux = User.where(statut: 'Bureau Sectoriel').order(nom: :asc)
      @organismes = Organisme.where.not(id: @organisme.id).sort_by { |organisme| normalize_name(organisme.nom) }.pluck(:nom, :id, :siren, :etat)
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
    @organisme = Organisme.find(params[:id])
    redirect_to root_path and return unless @statut_user == '2B2O' || current_user == @organisme.controleur

    organismes_to_link = params[:organisme].delete(:organismes)
    ministeres_to_link = params[:organisme].delete(:ministeres)
    reset_values([:date_dissolution, :effet_dissolution]) if params[:organisme][:etat]
    reset_values([:nature_controle, :texte_soumission_controle, :autorite_controle, :texte_reglementaire_controle, :arrete_controle, :document_controle_present, :document_controle_lien, :document_controle_date, :arrete_nomination]) if params[:organisme][:presence_controle]
    reset_values([:admin_db_fonction]) if params[:organisme][:admin_db_present]
    reset_values([:delegation_approbation]) if params[:organisme][:tutelle_financiere]
    if @organisme.statut == 'valide'
      modifications = generate_modifications(ministeres_to_link)
      create_modifications(modifications)
    end
    if @statut_user == '2B2O'
      if params[:organisme][:statut] && params[:organisme][:statut] != 'valide'
        step = params[:organisme][:statut].to_i + 1
        params[:organisme][:statut] = @organisme.statut.to_i > params[:organisme][:statut].to_i ? @organisme.statut : params[:organisme][:statut] # pour garder étape si retour en arrière
      end
      @organisme.update(organisme_params)
      update_organisme_rattachements(organismes_to_link)
      update_organisme_ministeres(ministeres_to_link)
      update_modifications_attente(@organisme)
    end
    redirect_to @organisme.statut == 'valide' ? @organisme : edit_organisme_path(@organisme, step: step)
  end

  def destroy
    redirect_to root_path and return unless @statut_user == '2B2O'

    @organisme = Organisme.find(params[:id]).destroy
    respond_to do |format|
      format.turbo_stream { redirect_to organismes_path }
    end
  end

  def import
    redirect_to root_path and return unless current_user.statut == '2B2O'

    file = params[:file]
    Organisme.import(file) if file.present?
    respond_to do |format|
      format.turbo_stream { redirect_to organismes_path }
    end
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

  def set_famille
    if @statut_user == 'Controleur'
      @familles = current_user.controleur_organismes.pluck(:famille).uniq.reject { |element| element == 'Aucune' }
    elsif @statut_user == 'Bureau Sectoriel'
      @familles = current_user.bureau_organismes.pluck(:famille).uniq.reject { |element| element == 'Aucune' }
    end
  end

  def update_organisme_rattachements(organismes_to_link)
    @organisme.organisme_rattachements.destroy_all if @organisme.etat != 'Inactif'
    if organismes_to_link && organismes_to_link.map(&:to_i).reject { |element| element == 0 } != @organisme.organisme_rattachements.pluck(:organisme_destination_id)
      @organisme.organisme_rattachements.destroy_all
      selected_organismes = organismes_to_link || [] # Récupérer les valeurs cochées
      selected_organismes.map(&:to_i).reject { |element| element == 0 }.each do |organisme_id|
        @organisme.organisme_rattachements.create(organisme_destination_id: organisme_id)
      end
    end
  end

  def update_organisme_ministeres(ministeres_to_link)
    if ministeres_to_link && ministeres_to_link.map(&:to_i).reject { |element| element == 0 } != @organisme.organisme_ministeres.pluck(:ministere_id)
      @organisme.organisme_ministeres.destroy_all
      selected_ministeres = ministeres_to_link || []
      selected_ministeres.map(&:to_i).reject { |element| element == 0 }.each do |ministere_id|
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
    champs_a_surveiller = [:nom, :etat, :acronyme, :siren, :nature, :texte_institutif, :gbcp_1, :gbcp_3,
                           :comptabilite_budgetaire, :nature_controle, :texte_soumission_controle, :autorite_controle,
                           :texte_reglementaire_controle, :arrete_controle, :document_controle_date, :comite_audit,
                           :arrete_nomination, :ciassp_n, :ciassp_n1, :odal_n, :odal_n1, :odac_n, :odac_n1]
    champs_texte = ['Nom', 'État', 'Acronyme', 'Siren', 'Nature juridique', 'Texte institutif', 'Partie I GBCP',
                    'Partie III GBCP', 'Comptabilité budgétaire', 'Nature contrôle', 'Texte soumission au contrôle',
                    'Autorité de contrôle', "Texte réglementaire de désignation de l'autorité de contrôle",
                    'Arrêté de contrôle', 'Date signature document contrôle ', 'Comité audit et risques',
                    'Arrêté de nomination comissaire du gouvernement', "CIASSP #{(Date.today.year).to_s}",
                    "CIASSP #{(Date.today.year - 1).to_s}", "ODAL #{(Date.today.year - 2).to_s}",
                    "ODAL #{(Date.today.year - 3).to_s}", "ODAC #{(Date.today.year - 2).to_s}",
                    "ODAC #{(Date.today.year - 3).to_s}"]
    champs_supp_controleur = [:date_creation, :date_previsionnelle_dissolution, :agent_comptable_present,
                              :degre_gbcp, :document_controle_present, :document_controle_lien, :ministere_id,
                              :admin_db_present, :admin_db_fonction, :admin_preca, :controleur_preca, :controleur_ca]
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
      if ministeres_to_link && ministeres_to_link.map(&:to_i).reject { |element| element == 0 } != @organisme.organisme_ministeres.pluck(:ministere_id)
        nouvelle_valeur = ministeres_to_link.map(&:to_i).reject { |element| element == 0 }
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
end
