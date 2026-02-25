# frozen_string_literal: true

# Controller Pages operateurs
class OperateursController < ApplicationController
  before_action :authenticate_admin!
  def index
    @operateurs = Operateur.all
  end

  def new
    @organisme = Organisme.find(params[:organisme_id])
    @operateur = Operateur.new
    @programmes = Programme.all.order(numero: :asc)
    @liste_operateur = @operateur.operateur_programmes.pluck(:programme_id)
  end
  def create
    @organisme = Organisme.find(params[:operateur][:organisme_id])
    programmes_to_link = params[:operateur].delete(:programmes)
    @operateur = Operateur.new(operateur_params)
    if params[:operateur][:operateur_actif] == 'true' && params[:operateur][:annee_debut].present?
      if @operateur.save
        @operateur.activer!(params[:operateur][:annee_debut].to_i)
        update_operateur_programmes(programmes_to_link)
      end
    end
    redirect_to organisme_path(@organisme)
  end

  def edit
    @organisme = Organisme.find(params[:organisme_id])
    @operateur = Operateur.find(params[:id])
    @programmes = Programme.all.order(numero: :asc)
    @liste_operateur = @operateur.operateur_programmes.pluck(:programme_id)
  end

  def update
    @organisme = Organisme.find(params[:operateur][:organisme_id])
    @operateur = Operateur.find(params[:id])
    programmes_to_link = params[:operateur].delete(:programmes)
    @operateur.update(operateur_params)
    if params[:operateur][:operateur_actif] == 'false'
      @operateur.desactiver!(Date.today.year)
    elsif params[:operateur][:annee_debut].present?
      @operateur.activer!(params[:operateur][:annee_debut].to_i)
    end
    update_operateur_programmes(programmes_to_link)
    redirect_to organisme_path(@organisme)
  end

  def import
    file = params[:file]
    Operateur.import(file) if file.present?
    respond_to do |format|
      format.turbo_stream { redirect_to operateurs_path }
    end
  end

  private

  def operateur_params
    params.require(:operateur).permit(:organisme_id, :presence_categorie,
                                      :nom_categorie, :mission_id, :programme_id)
  end

  def update_operateur_programmes(programmes_to_link)
    if programmes_to_link && programmes_to_link.map(&:to_i).reject { |element| element == 0 } != @operateur.operateur_programmes.pluck(:programme_id)
      @operateur.operateur_programmes.destroy_all
      selected_programmes = programmes_to_link || []
      selected_programmes.map(&:to_i).reject { |element| element == 0 }.each do |programme_id|
        @operateur.operateur_programmes.create(programme_id: programme_id)
      end
    end
  end

end
