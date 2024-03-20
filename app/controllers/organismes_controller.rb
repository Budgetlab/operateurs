# frozen_string_literal: true

# Controller Pages organismes
require 'google/cloud/storage'

class OrganismesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_famille, only: %i[index show]
  def index
    params.permit![:format] # pour le link_to excel
    # Fetch all organisms relevant to user's permissions, including those in extended families
    extended_family_organisms = fetch_extended_family_organisms
    # Fetch only the organisms directly under the user's control
    @controlled_organisms = fetch_controlled_organisms(extended_family_organisms)
    # Calculate the total repartition counts for these organisms and appropriate box titles
    @organisms_counts_by_repartition = count_organisms_by_repartition_status(@controlled_organisms)
    # Prepare a sorted list of organisms for search
    @search_organismes = extended_family_organisms&.pluck(:id, :nom, :acronyme)&.sort_by { |organisme| organisme[1] }
    @controleur_name_list = User.where(statut: ['Controleur', '2B2O']).order(:nom).pluck(:nom)
    @q = extended_family_organisms.ransack(params[:q])
    @extended_family_organisms = @q.result.includes(:bureau, :chiffres, :controleur, :ministere, :modifications, :operateur, :organisme_destinations, :organisme_ministeres, :organisme_rattachements)
    @pagy, @organisms_page = pagy(@extended_family_organisms)
    respond_to do |format|
      format.html
      format.any do
        headers['Content-Disposition'] = "attachment; filename=\"Liste_fiches_identite_organismes.xlsx\""
        render xlsx: 'index', filename: 'Liste_fiches_identite_organismes.xlsx', disposition: 'attachment'
      end
    end
  end

  def show
    @organisme = Organisme.includes(:ministere, :bureau, :controleur, :organisme_ministeres).find(params[:id])
    est_controleur = current_user == @organisme.controleur
    est_bureau_ou_famille = current_user == @organisme.bureau || @familles&.include?(@organisme.famille)
    redirect_to root_path and return unless @statut_user == '2B2O' || est_controleur || est_bureau_ou_famille

    @admin = @statut_user == '2B2O' || (est_controleur && @organisme.etat != 'Inactif')
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
      format.xlsx { headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" }
    end
  end

  def new
    redirect_to root_path and return unless @statut_user == '2B2O'

    @organisme = Organisme.new
    @bureaux = User.where(statut: 'Bureau Sectoriel').order(nom: :asc)
    @organismes = Organisme.where.not(id: @organisme.id).sort_by { |organisme| normalize_name(organisme.nom) }.pluck(:nom, :id, :siren, :etat, :acronyme)
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
    @organisme = Organisme.find(params[:id])
    redirect_to root_path and return unless @statut_user == '2B2O' || current_user == @organisme.controleur

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
    redirect_to root_path and return unless @statut_user == '2B2O'

    @organisme = Organisme.find(params[:id]).destroy
    respond_to do |format|
      format.turbo_stream { redirect_to organismes_path }
    end
  end

  def documents_controle
    organismes = liste_organisme
    array_organismes = organismes.where.not(document_controle_lien: nil).order(document_controle_date: :desc).pluck(:controleur_id, :id, :nom, :document_controle_lien, :document_controle_date, :nature_controle, :arrete_controle)
    @grouped_organismes = array_organismes.group_by(&:first)
    @users_hash = User.pluck(:id, :nom).to_h
  end

  def create_document_controle
    @organisme = Organisme.find(params[:id])
    file = params[:file]
    redirect_to @organisme and return if file.nil?

    # Téléchargement du fichier sur GCS
    bucket_name = 'budgetlab-bucket'
    storage = Google::Cloud::Storage.new(project_id: 'apps-354210')
    bucket = storage.bucket(bucket_name)
    nom_fichier = "OPERA/Controle/#{@organisme.id.to_s}_#{file.original_filename}"
    file = bucket.create_file(file.tempfile, nom_fichier)

    # Enregistrement du lien du fichier dans la base de données
    @organisme.update(document_controle_lien: file.public_url)
    redirect_to @organisme, flash: { notice: 'ajout_dc' }
  end

  def destroy_document_controle
    @organisme = Organisme.find(params[:id])
    # Suppression du fichier dans GCS
    bucket_name = 'budgetlab-bucket'
    storage = Google::Cloud::Storage.new(project_id: 'apps-354210')
    bucket = storage.bucket(bucket_name)
    filename = @organisme.document_controle_lien&.gsub('https://storage.googleapis.com/budgetlab-bucket/', '')
    # Supprimez le fichier dans GCS en utilisant son chemin ou son nom
    bucket.file(filename)&.delete

    # Supprimez le document de la base de données
    @organisme.update(document_controle_lien: nil)
    redirect_to @organisme, flash: { notice: 'suppression_dc' }
  end

  def download_document
    @organisme = Organisme.find(params[:id])
    bucket_name = 'budgetlab-bucket'
    storage = Google::Cloud::Storage.new(project_id: 'apps-354210')
    bucket = storage.bucket(bucket_name)
    @lien = @organisme.document_controle_lien
    # filename = File.basename(URI.parse(@lien).path)
    filename = @organisme.document_controle_lien&.gsub('https://storage.googleapis.com/budgetlab-bucket/', '')
    file = bucket.file(filename)
    # Téléchargez le contenu du fichier PDF
    file_content = file.download.read
    send_data file_content, :filename => filename, :disposition => "inline"
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
      @familles += ['Universités'] if current_user.nom == 'CBCM MEN-MESRI'
    elsif @statut_user == 'Bureau Sectoriel'
      @familles = current_user.bureau_organismes.pluck(:famille).uniq.reject { |element| element == 'Aucune' }
    end
  end

  def fetch_extended_family_organisms
    organisms = Organisme.all.includes(:controleur)
    case @statut_user
    when 'Controleur'
      organisms = organisms.where(statut: 'valide').where("controleur_id = :user_id OR famille IN (:familles)", user_id: current_user.id, familles: @familles)
    when 'Bureau Sectoriel'
      organisms = organisms.where(statut: 'valide').where("bureau_id = :user_id OR famille IN (:familles)", user_id: current_user.id, familles: @familles)
    end
    organisms.order(:nom)
  end

  def fetch_controlled_organisms(organisms)
    case @statut_user
    when 'Controleur'
      organisms.where(controleur_id: current_user)
    when 'Bureau Sectoriel'
      organisms.where(bureau_id: current_user)
    else
      organisms
    end
  end

  def count_organisms_by_repartition_status(organisms)
    active_organisms = organisms.where(etat: 'Actif')
    case @statut_user
    when '2B2O'
      count_for_2b2o(active_organisms)
    when 'Controleur'
      count_for_controleur(active_organisms)
    when 'Bureau Sectoriel'
      count_for_bs(active_organisms)
    end
  end

  def count_for_2b2o(active_organisms)
    active_organisms_gbcp_3 = active_organisms.count { |el| el.gbcp_3 == true }
    active_organisms_cb = active_organisms.count { |el| ['Oui', 'Oui mais adaptée'].include?(el.comptabilite_budgetaire) }
    active_organisms_hcb = active_organisms.count { |el| el.comptabilite_budgetaire == 'Non' }
    [active_organisms.count, active_organisms_gbcp_3, active_organisms_cb, active_organisms_hcb]
  end

  def count_for_controleur(active_organisms)
    active_operators = active_organisms.joins(:operateur).where.not(operateurs: { id: nil }).where(operateurs: { operateur_n: true }).count
    organisms_active_cb = active_organisms.count { |el| el.nature_controle == 'Contrôle Budgétaire' }
    organisms_active_cef = active_organisms.count { |el| el.nature_controle == 'Contrôle Economique et Financier' }
    organisms_active_epscp = active_organisms.count { |el| el.nature_controle == 'Contrôle Budgétaire EPSCP' }
    [active_operators, organisms_active_cb, organisms_active_cef, organisms_active_epscp]
  end

  def count_for_bs(active_organisms)
    active_operators = active_organisms.joins(:operateur).where.not(operateurs: { id: nil }).where(operateurs: { operateur_n: true }).count
    organisms_active_controlled = active_organisms.count { |el| !el.nature_controle.nil? }
    organisms_active_cb = active_organisms.count { |el| ['Oui', 'Oui mais adaptée'].include?(el.comptabilite_budgetaire) }
    organisms_active_tutelle = active_organisms.count { |el| el.tutelle_financiere == true }
    [active_operators, organisms_active_controlled, organisms_active_cb, organisms_active_tutelle]
  end

  def apply_filters_to_organisms(organisms)
    # Initialize filters from params
    filters = {
      etat: parse_params(params[:etat], nil),
      famille: parse_params(params[:famille], nil),
      nature: parse_params(params[:nature], nil),
      controleur_id: parse_params(params[:controleur_id], nil),
      nature_controle: parse_params(params[:nature_controle], nil),
    }
    statut_brouillon = parse_params(params[:statut], nil)&.include?('Brouillon')
    # Start with all organisms
    filtered_organisms = organisms
    # Apply filters if selections are present
    filters.each do |key, value|
      filtered_organisms = filtered_organisms.where(key => value) if value.present?
    end
    # Filter only on statut brouillon if brouillon selected
    filtered_organisms = filtered_organisms.where.not(statut: 'valide') if statut_brouillon
    # Filters on operateur
    operateur_filter = parse_params(params[:operateur], nil)
    filtered_organisms = filter_operateur(filtered_organisms, operateur_filter) if operateur_filter&.length == 1
    filtered_organisms
  end


  # This helper method is used to parse params and return the value if it exists,
  # otherwise returns the provided default list
  def parse_params(param, default_list)
    if param.present? && JSON.parse(param).to_a.any?
      return JSON.parse(param)
    end
    default_list
  end

  def filter_operateur(organisms, param)
    if param == ['Oui']
      organisms.joins(:operateur).where.not(operateurs: { id: nil }).where(operateurs: { operateur_n: true })
    elsif param == ['Non']
      organisms.left_outer_joins(:operateur).where('operateurs.id IS NULL OR operateurs.operateur_n = ?', false)
    else
      organisms
    end
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

end
