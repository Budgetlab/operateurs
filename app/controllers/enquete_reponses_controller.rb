class EnqueteReponsesController < ApplicationController
  # before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:new, :import]

  def index
    @enquete_annees = Enquete.order(annee: :asc).pluck(:annee)
    unless @enquete_annees.empty?
      @annee_a_afficher = params[:annee] ? params[:annee].to_i : @enquete_annees.last # prendre la plus récente
      @enquete = Enquete.find_by(annee: @annee_a_afficher.to_i)
      redirect_to enquete_reponses_path and return unless @enquete
      @reponses = @enquete.enquete_reponses.count
      @questions = @enquete.enquete_questions.order(:numero)
      @resultats = @questions.each_with_object({}) do |question, result|
        result[question.nom] = EnqueteReponse
                                 .where(enquete_id: @enquete.id)
                                 .group("reponses->>'#{question.id}'")
                                 .count
      end
      @resultats = @resultats.transform_values { |reponses| reponses.sort.to_h }
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
