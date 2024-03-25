# frozen_string_literal: true

# Controller for Control documents
class ControlDocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_control_document, only: %i[destroy]
  before_action :redirect_unless_admin, only: %i[documents controleur_documents destroy]
  before_action :set_organisme, only: %i[new]
  def index
    @control_documents = if @statut_user == 'Controleur'
                           current_user.control_documents.includes(:user, :organisme).order(created_at: :desc)
                         else
                           ControlDocument.all.includes(:user, :organisme).order(created_at: :desc)
                         end
  end

  def new
    @control_document = @organisme.control_documents.new
  end

  def create
    @control_document = ControlDocument.new(control_document_params)
    flash[:notice] = @control_document.save ? 'control_document_success' : 'control_document_failed'
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('control_document', partial: 'control_documents/control_document', locals: {control_document: @control_document})
      end
    end
  end

  def destroy
    @organisme = @control_document.organisme
    @control_document.document&.purge
    @control_document&.destroy
    redirect_to @organisme, flash: { notice: 'suppression_dc' }
  end

  def documents
    @controleurs = User.where(statut: ['Controleur', '2B2O']).includes(:control_documents)
  end

  def controleur_documents
    @controleur = User.find_by(nom: params[:user])
    redirect_to documents_path and return unless @controleur
  end

  private

  def set_control_document
    @control_document = ControlDocument.find(params[:id])
  end

  def control_document_params
    params.require(:control_document).permit(:name, :gcp_link, :user_id, :organisme_id, :signature_date, :document)
  end

  def redirect_unless_admin
    redirect_to root_path and return unless @statut_user == '2B2O'
  end

  def set_organisme
    @organisme = Organisme.find(params[:organisme_id])
  end
end
