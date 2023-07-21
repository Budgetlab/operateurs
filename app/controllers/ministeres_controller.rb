# frozen_string_literal: true

# Controller Pages Ministeres
class MinisteresController < ApplicationController
  before_action :authenticate_user!
  protect_from_forgery with: :null_session
  def index
    redirect_to root_path and return unless current_user.statut == '2B2O'

    @noms_ministeres = Ministere.all.pluck(:nom)
  end

  def import
    redirect_to root_path and return unless current_user.statut == '2B2O'

    Ministere.import(params[:file])
    respond_to do |format|
      format.turbo_stream { redirect_to ministeres_path }
    end
  end
end
