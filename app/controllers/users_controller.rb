# frozen_string_literal: true

# Controller Users
class UsersController < ApplicationController
  protect_from_forgery with: :null_session
  def index
    # redirect_to root_path unless current_user && current_user.statut != '2B2O'
    @noms_users = User.all.pluck(:nom)
    @familles = Organisme.all.pluck(:famille).uniq
    @natures = Organisme.all.pluck(:nature).uniq
  end

  def import
    User.import(params[:file])
    respond_to do |format|
      format.turbo_stream { redirect_to users_path }
    end
  end

  def select_nom
    noms = !params[:statut].nil? && !params[:statut].blank? ? User.where(statut: params[:statut]).order(nom: :asc).pluck(:nom) : nil
    response = { noms: noms }
    render json: response
  end
end
