# frozen_string_literal: true

# Controller Pages operateurs
class OperateursController < ApplicationController
  def index
    redirect_to root_path and return unless @statut_user == '2B2O'

    @operateurs = Operateur.all
  end

  def new
    @organisme = Organisme.find(params[:organisme_id])
    redirect_to root_path and return unless @statut_user == '2B2O' && @organisme

    @operateur = Operateur.new
    @programmes = Programme.all.order(numero: :asc)
    @liste_operateur = @operateur.operateur_programmes.pluck(:programme_id)
  end
  def create
    @organisme = Organisme.find(params[:operateur][:organisme_id])
    redirect_to root_path and return unless @statut_user == '2B2O' && @organisme

    programmes_to_link = params[:operateur].delete(:programmes)
    @operateur = Operateur.new(operateur_params)
    @operateur.save if @operateur.operateur_nf == true || @operateur.operateur_n == true || @operateur.operateur_n1 == true || @operateur.operateur_n2 == true
    update_operateur_programmes(programmes_to_link)
    redirect_to organisme_path(@organisme)
  end

  def edit
    @organisme = Organisme.find(params[:organisme_id])
    redirect_to root_path and return unless @statut_user == '2B2O' && @organisme

    @operateur = Operateur.find(params[:id])
    @programmes = Programme.all.order(numero: :asc)
    @liste_operateur = @operateur.operateur_programmes.pluck(:programme_id)
  end

  def update
    @organisme = Organisme.find(params[:operateur][:organisme_id])
    redirect_to root_path and return unless @statut_user == '2B2O' && @organisme

    @operateur = Operateur.find(params[:id])
    programmes_to_link = params[:operateur].delete(:programmes)
    params[:operateur][:nom_categorie] = params[:operateur][:nom_categorie]
    @operateur.update(operateur_params)
    @operateur.destroy if @operateur.operateur_nf == false && @operateur.operateur_n == false && @operateur.operateur_n1 == false && @operateur.operateur_n2 == false
    update_operateur_programmes(programmes_to_link)
    redirect_to organisme_path(@organisme)
  end

  def import
    redirect_to root_path and return unless @statut_user == '2B2O'

    file = params[:file]
    Operateur.import(file) if file.present?
    respond_to do |format|
      format.turbo_stream { redirect_to operateurs_path }
    end
  end

  private

  def operateur_params
    params.require(:operateur).permit(:organisme_id, :operateur_nf, :operateur_n, :operateur_n1, :operateur_n2, :presence_categorie,
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
