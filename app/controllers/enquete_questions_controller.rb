class EnqueteQuestionsController < ApplicationController
  before_action :authenticate_admin!
  def index
    @questions = EnqueteQuestion.all.includes(:enquete)
  end
end
