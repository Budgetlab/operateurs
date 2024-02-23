# frozen_string_literal: true

# Controller Pages Ministeres
class MinisteresController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_admin
  protect_from_forgery with: :null_session
  def index
    @ministeres = Ministere.all.order(nom: :asc)
  end

  def create
    @ministere = Ministere.new(ministere_params)
    @ministere.save
    redirect_to ministeres_path
  end

  def edit
    @ministere = Ministere.find(params[:id])
  end

  def update
    @ministere = Ministere.find(params[:id])
    @ministere.update(ministere_params)
    redirect_to ministeres_path
  end

  def import
    redirect_to root_path and return unless @statut_user == '2B2O'

    Ministere.import(params[:file])
    respond_to do |format|
      format.turbo_stream { redirect_to ministeres_path }
    end
  end

  private

  def ministere_params
    params.require(:ministere).permit(:nom)
  end

  def redirect_admin
    redirect_to root_path and return unless @statut_user == '2B2O'
  end
end
