class EnqueteReponsesController < ApplicationController
  # before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:new, :import]

  def index
    @enquete_annees = Enquete.order(annee: :asc).pluck(:annee)
    unless @enquete_annees.empty?
      @annee_a_afficher = params[:annee] ? params[:annee].to_i : @enquete_annees.last # prendre la plus récente
      @enquete = Enquete.find_by(annee: @annee_a_afficher.to_i)
      redirect_to enquete_reponses_path and return unless @enquete

      @reponses = @enquete.enquete_reponses
      @questions = @enquete.enquete_questions.where.not(numero: [15, 29, 31]).order(:numero)
      @resultats = @questions.each_with_object({}) do |question, result|
        all_responses = EnqueteReponse
                          .where(enquete_id: @enquete.id)
                          .group("reponses->>'#{question.id}'")
                          .count

        if current_user.statut == "Controleur"
          cbr_responses = EnqueteReponse
                            .where(enquete_id: @enquete.id)
                            .where(organisme_id: current_user.controleur_organismes.pluck(:id))
                            .group("reponses->>'#{question.id}'")
                            .count

          result["#{question.numero}. #{question.nom}"] = {
            'Total' => all_responses.sort.to_h,
            'Contrôleur référent' => cbr_responses.sort.to_h
          }
        else
          result["#{question.numero}. #{question.nom}"] = {
            Total: all_responses.sort.to_h
          }
        end
      end
    end
    respond_to do |format|
      format.html
      format.pdf do
        if @enquete.document.attached? # vérifiez si un pdf est attaché
          send_data(
            @enquete.document.download, # envoyez le pdf attaché
            filename: @enquete.document.filename.to_s,
            type: "application/pdf",
            disposition: "attachment"
          )
        else
          url = enquete_reponses_url(annee: @annee_a_afficher)
          pdf_data = UrlToPdfJob.perform_now(url)
          send_data(pdf_data,
                    filename: "enquete_#{@annee_a_afficher}.pdf",
                    type: "application/pdf",
                    disposition: "attachment") # inline open in browser
        end
      end
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
