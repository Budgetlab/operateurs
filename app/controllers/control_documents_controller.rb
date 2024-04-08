# frozen_string_literal: true

# Controller for Control documents
class ControlDocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_control_document, only: %i[edit destroy]
  before_action :set_organisme, only: %i[new]
  def index
    control_documents = fetch_extended_family_documents
    @q = control_documents.ransack(params[:q])
    @control_documents = @q.result.includes(organisme: :controleur)
  end

  def new
    @control_document = @organisme.control_documents.new
  end

  def create
    @control_document = ControlDocument.new(control_document_params)
    flash[:notice] = @control_document.save && @control_document.document.attached? ? 'control_document_success' : 'control_document_failed'
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('control_document', partial: 'control_documents/control_document', locals: {organisme: @control_document.organisme})
      end
    end
  end

  def edit; end

  def destroy
    @control_document&.destroy
    redirect_to control_documents_path, flash: { notice: 'control_document_deleted' }
  end

  private

  def set_control_document
    @control_document = ControlDocument.find(params[:id])
  end

  def control_document_params
    params.require(:control_document).permit(:name, :user_id, :organisme_id, :signature_date, :document)
  end

  def set_organisme
    @organisme = Organisme.find(params[:organisme_id])
  end

  def fetch_extended_family_documents
    control_documents = ControlDocument.all
    case @statut_user
    when 'Controleur'
      control_documents = control_documents.joins(:organisme).where('organismes.controleur_id = :user_id OR organismes.famille IN (:familles)', user_id: current_user.id, familles: @familles)
    when 'Bureau Sectoriel'
      control_documents = control_documents.joins(:organisme)
    end
    control_documents.order(signature_date: :desc)
  end
end
