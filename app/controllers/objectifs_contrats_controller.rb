class ObjectifsContratsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_objectifs_contrat, only: %i[edit destroy]
  before_action :set_organisme, only: %i[new]
  def index
    objectifs_contrats = fetch_extended_family_documents
    @q = objectifs_contrats.ransack(params[:q])
    @objectifs_contrats = @q.result.includes(organisme: :controleur)
    @pagy, @objectifs_contrats_page = pagy(@objectifs_contrats)
  end

  def new
    @objectifs_contrat = @organisme.objectifs_contrats.new
  end

  def create
    @objectifs_contrat = current_user.objectifs_contrats.new(objectif_contrat_params)
    flash[:notice] = @objectifs_contrat.save && @objectifs_contrat.document.attached? ? 'objectifs_contrat_success' : 'objectifs_contrat_failed'
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('objectifs_contrat', partial: 'objectifs_contrats/objectifs_contrat', locals: {organisme: @objectifs_contrat.organisme})
      end
    end
  end

  def edit; end

  def destroy
    @objectifs_contrat&.destroy
    redirect_to objectifs_contrats_path, flash: { notice: 'objectifs_contrat_deleted' }
  end


  private

  def set_objectifs_contrat
    @objectifs_contrat = ObjectifsContrat.find(params[:id])
  end

  def objectif_contrat_params
    params.require(:objectifs_contrat).permit(:nom, :user_id, :organisme_id, :debut,:fin, :document)
  end

  def set_organisme
    @organisme = Organisme.find(params[:organisme_id])
  end

  def fetch_extended_family_documents
    objectifs_contrats = ObjectifsContrat.all
    case @statut_user
    when 'Controleur'
      objectifs_contrats = objectifs_contrats.joins(:organisme).where('organismes.controleur_id = :user_id OR organismes.famille IN (:familles)', user_id: current_user.id, familles: @familles)
    when 'Bureau Sectoriel'
      objectifs_contrats = objectifs_contrats.joins(:organisme)
    end
    objectifs_contrats.order(fin: :desc)
  end
end
