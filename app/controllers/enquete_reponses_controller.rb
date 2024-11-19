class EnqueteReponsesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:new, :import]
  def index
    @reponses = EnqueteReponse.all
    @annee = params[:annee] || 2024
    @enquete = Enquete.find_by(annee: @annee)
    @questions = @enquete.enquete_questions.order(:numero)
    @resultats = @questions.each_with_object({}) do |question, result|
      result[question.nom] = EnqueteReponse
                               .where(enquete_id: @enquete.id)
                               .group("reponses->>'#{question.id}'")
                               .count
      end
  end

  def new
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
