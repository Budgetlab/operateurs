# frozen_string_literal: true

# Controller Pages organismes
class OrganismesController < ApplicationController
  before_action :authenticate_user!
  def index
    @organismes = Organisme.all.pluck(:id, :nom, :statut, :etat)
    @organismes_actifs = @organismes.select { |el| el[2] == 'valide' && el[3] == 'Actif' }
    @organismes_inactifs = @organismes.select { |el| el[2] == 'valide' && el[3] == 'Inactif' }
    @organismes_creation = @organismes.select { |el| el[2] == 'valide' && el[3] == 'En cours de création' }
    @organismes_brouillon = @organismes.reject { |el| el[2] == 'valide' }

  end

  def organismes_ajout
    @organismes_noms = Organisme.all.pluck(:nom)
  end

  def show
    @organisme = Organisme.find(params[:id])
    @operateur = @organisme.operateur
  end

  def new
    @organisme = Organisme.new
    @bureaux = User.where(statut: 'Bureau Sectiorel').order(nom: :asc)
    @organismes = Organisme.all.order(nom: :asc).pluck(:nom, :id, :siren)
    @noms_organismes = @organismes.map { |el| el[0] }
    @siren_organismes = @organismes.map { |el| el[2] }.compact
  end

  def create
    @organisme = params[:organisme][:id] ? Organisme.find(:id).assign_attributes(organisme_params) : Organisme.new(organisme_params)
    @organisme.controleur = User.where(statut: '2B2O').first if @organisme.controleur_id.nil?
    @organisme.ministere = Ministere.first if @organisme.ministere_id.nil?
    if @organisme.etat == 'Inactif' && (@organisme.effet_dissolution == 'Création' || @organisme.effet_dissolution == 'Rattachement')
      params[:organisme][:organismes].each do |id|
        @organisme_rattachement = @organisme.organisme_rattachements.new(organisme_destination_id: id)
        @organisme_rattachement.save
      end
    end
    if @organisme.save
      redirect_to edit_organisme_path(@organisme.id)
    else
      render :new
    end
  end

  def edit
    @organisme = Organisme.find(params[:id])
    if params[:step].to_i == 1
      @bureaux = User.where(statut: 'Bureau Sectiorel').order(nom: :asc)
      @organismes = Organisme.where.not(id: @organisme.id).order(nom: :asc).pluck(:nom, :id, :siren)
      @noms_organismes = @organismes.map { |el| el[0] }
      @siren_organismes = @organismes.map { |el| el[2] }.compact
    end
    @controleurs = User.where(statut: 'Controleur').order(nom: :asc)
    @ministeres = Ministere.order(nom: :asc)
  end

  def update
    @organisme = Organisme.find(params[:id])
    reset_values([:date_previsionnelle_dissolution, :date_dissolution, :effet_dissolution]) if params[:organisme][:etat]
    reset_values([:nature_controle, :texte_soumission_controle, :autorite_controle, :texte_reglementaire_controle, :arrete_controle, :document_controle_present, :document_controle_lien, :document_controle_date, :arrete_nomination]) if params[:organisme][:presence_controle]
    reset_values([:admin_db_fonction]) if params[:organisme][:admin_db_present]
    reset_values([:delegation_approbation, :autorite_approbation]) if params[:organisme][:tutelle_financiere]
    if @organisme.update(organisme_params)
      @organisme.organisme_rattachements.destroy_all if @organisme.etat != 'Inactif'
      if params[:organisme][:organismes] && @organisme.etat == 'Inactif' && (@organisme.effet_dissolution == 'Création' || @organisme.effet_dissolution == 'Rattachement')
        @organisme.organisme_rattachements.destroy_all
        selected_organismes = params[:organisme][:organismes] || [] # Récupérer les valeurs cochées
        selected_organismes.each do |organisme_id|
          @organisme.organisme_rattachements.create(organisme_destination_id: organisme_id)
        end
      end
      if params[:organisme][:ministeres]
        @organisme.organisme_ministeres.destroy_all
        selected_ministeres = params[:organisme][:ministeres] || []
        selected_ministeres.each do |ministere_id|
          @organisme.organisme_ministeres.create(ministere_id: ministere_id)
        end
      end
      if @organisme.statut == 'valide'
        redirect_to @organisme
      else
        redirect_to edit_organisme_path
      end
    else
      render :edit
    end
  end

  def destroy
    @organisme = Organisme.find(params[:id]).destroy_all
    respond_to do |format|
      format.turbo_stream { redirect_to organismes_path }
    end
  end

  def import
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
                                      :degre_gbcp, :gbcp_3, :comptabilite_budgetaire, :presence_controle,:controleur_id,
                                      :nature_controle, :texte_soumission_controle, :autorite_controle,
                                      :texte_reglementaire_controle, :arrete_controle, :document_controle_present,
                                      :document_controle_lien, :document_controle_date, :arrete_nomination,
                                      :tutelle_financiere, :delegation_approbation, :autorite_approbation, :ministere_id,
                                      :admin_db_present, :admin_db_fonction, :admin_preca, :controleur_preca,
                                      :controleur_ca, :comite_audit, :apu, :ciassp_n, :ciassp_n1, :odac_n, :odac_n1,
                                      :odal_n, :odal_n1)
  end

  def reset_values(param_names)
    param_names.each do |param|
      params[:organisme][param.to_sym] = params[:organisme].fetch(param.to_sym, nil)
    end
  end
end
