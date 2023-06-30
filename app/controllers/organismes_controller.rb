# frozen_string_literal: true

# Controller Pages organismes
class OrganismesController < ApplicationController
  before_action :authenticate_user!
  def index
    @organismes_noms = Organisme.all.pluck(:nom)
  end

  def show
    @organisme = Organisme.find(params[:id])
  end

  def new; end

  def create; end

  def edit; end

  def update; end

  def destroy
    @organisme = Organisme.find(params[:id]).destroy_all
    respond_to do |format|
      format.turbo_stream { redirect_to organismes_path }
    end
  end

  def import
    file = params[:file]
    Organisme.import(file) if file.present?
    respond_to do |format|
      format.turbo_stream { redirect_to organismes_path }
    end
  end
end
