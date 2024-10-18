class EnqueteReponsesController < ApplicationController
  before_action :authenticate_admin!
  def index
    @reponses = EnqueteReponse.all
  end

  def show
    @enquete_reponse = EnqueteReponse.find(params[:id])
    @organisme = @enquete_reponse.organisme
    @questions_par_categorie = @enquete_reponse.enquete.enquete_questions.order(:numero).group_by(&:categorie)
  end

  def import
    file = params[:file]
    EnqueteReponse.import(file) if file.present?
    respond_to do |format|
      format.turbo_stream { redirect_to enquete_reponses_path }
    end
  end
end
