class EnqueteQuestionsController < ApplicationController
  before_action :authenticate_admin!
  def index
    @questions = EnqueteQuestion.all.includes(:enquete)
  end

  def import
    file = params[:file]
    EnqueteQuestion.import(file) if file.present?
    respond_to do |format|
      format.turbo_stream { redirect_to enquete_questions_path }
    end
  end
end
