class EnqueteReponsesController < ApplicationController
  # before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:new, :import]

  def index
    @enquete_annees = Enquete.order(annee: :asc).pluck(:annee)
    return if @enquete_annees.empty?

    @annee_a_afficher = params[:annee] ? params[:annee].to_i : @enquete_annees.last.to_i # prendre la plus récente
    @enquete = Enquete.find_by(annee: @annee_a_afficher)
    redirect_to enquete_reponses_path and return unless @enquete

    # filtrer les résultats
    @enquete_reponses = @enquete.enquete_reponses.joins(organisme: :controleur)
    @q = @enquete_reponses.ransack(params[:q])
    reponses = @q.result.includes(organisme: :controleur)
    @questions = @enquete.enquete_questions.where.not(numero: [15, 29, 31]).order(:numero)

    # construire les résultats
    @resultats = @questions.each_with_object({}) do |question, result|
      # Initialiser la structure de réponse avec le total
      all_responses = @enquete_reponses.group("reponses->>'#{question.id}'").count
      result["#{question.numero}. #{question.nom}"] = { 'Total' => all_responses.sort.to_h }

      # Calcul conditionnel des réponses CBR
      cbr_responses = nil
      if params.dig(:q, :organisme_controleur_nom_in).present?
        cbr_responses = @enquete_reponses
                          .where(controleur: { nom: params[:q][:organisme_controleur_nom_in] })
                          .group("reponses->>'#{question.id}'")
                          .count
        cbr_key = params[:q][:organisme_controleur_nom_in]
      elsif @statut_user == "Controleur"
        cbr_responses = @enquete_reponses
                          .where(organisme_id: current_user.controleur_organismes.pluck(:id))
                          .group("reponses->>'#{question.id}'")
                          .count
        cbr_key = current_user.nom
      end
      # Ajouter les réponses famille si filtre sur la famille
      famille_reponses = nil
      if params.dig(:q, :organisme_famille_in).present?
        famille_reponses = @enquete_reponses
                             .where(organismes: { famille: params[:q][:organisme_famille_in] })
                             .group("reponses->>'#{question.id}'")
                             .count
        famille_key = params[:q][:organisme_famille_in]
      end
      # Ajouter la série CBR et famille si elle existe
      result["#{question.numero}. #{question.nom}"][cbr_key] = cbr_responses.sort.to_h if cbr_responses
      result["#{question.numero}. #{question.nom}"][famille_key] = famille_reponses.sort.to_h if famille_reponses
    end

    respond_to do |format|
      format.html
      format.xlsx do
        headers['Content-Disposition'] = 'attachment; filename="Enquete.xlsx"'
        render xlsx: 'index', filename: 'Enquete.xlsx', disposition: 'attachment'
      end
    end
  end

  def new
    @enquetes = Enquete.all
    @reponses = EnqueteReponse.all
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
end
