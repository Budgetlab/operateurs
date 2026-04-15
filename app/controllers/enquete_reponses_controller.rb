class EnqueteReponsesController < ApplicationController
  # before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:new, :import, :destroy]

  def index
    @enquete_annees = Enquete.order(annee: :asc).pluck(:annee)
    return if @enquete_annees.empty?

    @controleur_name_list = User.where(statut: 'Controleur').order(:nom).pluck(:nom)

    @annee_a_afficher = params[:annee] ? params[:annee].to_i : @enquete_annees.last.to_i # prendre la plus récente
    @enquete = Enquete.find_by(annee: @annee_a_afficher)
    redirect_to enquete_reponses_path and return unless @enquete

    # Scope de base : toutes les réponses de l'année (le Total ne sera jamais filtré)
    @enquete_reponses = @enquete.enquete_reponses.joins(organisme: :controleur)
    @q = @enquete_reponses.ransack(params[:q])

    # Filtrer les questions selon l'année
    @questions = if @annee_a_afficher == 2025
                   @enquete.enquete_questions.where.not(numero: 14).order(:numero)
                 elsif [2023, 2024].include?(@annee_a_afficher)
                   @enquete.enquete_questions.where.not(numero: [15, 29, 31]).order(:numero)
                 else
                   @enquete.enquete_questions.order(:numero)
                 end

    # Pré-calculer les scopes filtrés (indépendants du Total)
    controleur_noms = params.dig(:q, :organisme_controleur_nom_in).presence
    famille_noms = params.dig(:q, :organisme_famille_in).presence

    # construire les résultats
    @resultats = @questions.each_with_object({}) do |question, result|
      grp = "reponses->>'#{question.id}'"

      # Total : toujours toutes les réponses de l'année
      all_responses = @enquete_reponses.group(grp).count
      result["#{question.numero}. #{question.nom}"] = { 'Total' => all_responses.sort.to_h }

      # Série CBR : filtre contrôleur (param ou utilisateur connecté)
      if controleur_noms
        cbr = @enquete_reponses.where(controleur: { nom: controleur_noms }).group(grp).count
        result["#{question.numero}. #{question.nom}"][controleur_noms] = cbr.sort.to_h
      elsif @statut_user == 'Controleur'
        cbr = @enquete_reponses.where(organisme_id: current_user.controleur_organismes.pluck(:id)).group(grp).count
        result["#{question.numero}. #{question.nom}"][current_user.nom] = cbr.sort.to_h
      end

      # Série Famille : filtre famille
      if famille_noms
        famille = @enquete_reponses.where(organismes: { famille: famille_noms }).group(grp).count
        result["#{question.numero}. #{question.nom}"][famille_noms] = famille.sort.to_h
      end
    end

    respond_to do |format|
      format.html
      format.xlsx do
        render xlsx: 'index', filename: 'Enquete.xlsx', disposition: 'attachment'
      end
    end
  end

  def new
    @enquetes = Enquete.all
    @reponses = EnqueteReponse.all

    # Statistiques par année
    @stats_par_annee = Enquete.order(annee: :desc).map do |enquete|
      {
        annee: enquete.annee,
        id: enquete.id,
        nb_enquetes: 1,
        nb_reponses: enquete.enquete_reponses.count
      }
    end
  end

  def show
    @enquete_reponse = EnqueteReponse.find(params[:id])
    @organisme = @enquete_reponse.organisme
    @questions = @enquete_reponse.enquete.enquete_questions.order(:numero)
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "enquete_#{@organisme.nom}_#{@enquete_reponse.enquete.annee}",
               template: "enquete_reponses/show",
               layout: 'pdf',
               disposition: 'inline',
               encoding: 'UTF-8'
      end
    end
  end

  def import
    file = params[:file]
    EnqueteReponse.import(file) if file.present?
    respond_to do |format|
      format.turbo_stream { redirect_to enquete_reponses_path }
    end
  end

  def destroy
    @enquete = Enquete.find(params[:id])
    annee = @enquete.annee

    if @enquete.destroy
      redirect_to new_enquete_reponse_path, notice: "L'enquête de l'année #{annee} a été supprimée avec succès."
    else
      redirect_to new_enquete_reponse_path, alert: "Erreur lors de la suppression de l'enquête."
    end
  end
end
