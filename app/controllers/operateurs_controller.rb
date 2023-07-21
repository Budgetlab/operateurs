# frozen_string_literal: true

# Controller Pages operatuers
class OperateursController < ApplicationController
  def index; end

  def new
    @operateur = Operateur.new
    @organisme = Organisme.find(params[:organisme_id])
    @programmes = Programme.all.order(numero: :asc)
    redirect_to root_path and return unless current_user.statut == '2B2O' || current_user == @organisme.controleur
  end
  def create
    @organisme = Organisme.find(params[:operateur][:organisme_id])
    redirect_to root_path and return unless current_user.statut == '2B2O'

    @operateur = Operateur.new(operateur_params)
    @operateur.save if @operateur.operateur_n == true || @operateur.operateur_n1 == true || @operateur.operateur_n2 == true
    selected_programmes = params[:operateur][:programmes] || [] # Récupérer les valeurs cochées
    selected_programmes.each do |programme_id|
      @operateur.operateur_programmes.create(programme_id: programme_id)
    end
    redirect_to organisme_path(@organisme)
  end

  def edit
    @operateur = Operateur.find(params[:id])
    @organisme = Organisme.find(params[:organisme_id])
    @programmes = Programme.all.order(numero: :asc)
    redirect_to root_path and return unless current_user.statut == '2B2O'
  end

  def update
    @organisme = Organisme.find(params[:operateur][:organisme_id])
    redirect_to root_path and return unless current_user.statut == '2B2O'

    @operateur = Operateur.find(params[:id])
    params[:operateur][:nom_categorie] = params[:operateur][:nom_categorie]
    @operateur.update(operateur_params)
    @operateur.destroy if @operateur.operateur_n == false && @operateur.operateur_n1 == false && @operateur.operateur_n2 == false
    @operateur.operateur_programmes.destroy_all
    selected_programmes = params[:operateur][:programmes] || [] # Récupérer les valeurs cochées
    selected_programmes.each do |programme_id|
      @operateur.operateur_programmes.create(programme_id: programme_id)
    end
      redirect_to organisme_path(@organisme)
  end

  private

  def operateur_params
    params.require(:operateur).permit(:organisme_id, :operateur_n, :operateur_n1, :operateur_n2, :presence_categorie,
                                      :nom_categorie, :mission_id, :programme_id )
  end
end
