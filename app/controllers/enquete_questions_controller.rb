class EnqueteQuestionsController < ApplicationController
  before_action :authenticate_admin!
  def index
    @questions = EnqueteQuestion.all.includes(:enquete)
    @questions_by_year = @questions.group_by { |q| q.enquete.annee }.sort.to_h
    @years = @questions_by_year.keys.sort
  end
end
