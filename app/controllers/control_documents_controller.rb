# frozen_string_literal: true

# Controller for Control documents
class ControlDocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_control_document, only: %i[show destroy]
  before_action :redirect_unless_admin, only: %i[documents controleur_documents destroy]
  before_action :set_organisme, only: %i[new]
  def index
    @control_documents = if @statut_user == 'Controleur'
                           current_user.control_documents.includes(:user, :organisme)
                         else
                           ControlDocument.all.includes(:user, :organisme)
                         end
  end

  def new
    @control_document = @organisme.control_documents.new
  end
  def create
    file = params[:control_document][:file]
    @control_document = ControlDocument.new(control_document_params)
    # Téléchargement du fichier sur GCS
    bucket = retrieve_gcp_bucket
    file_name = "OPERA/Controle/#{@control_document.id}_#{@control_document.organisme.nom.to_s}_#{file.original_filename}"
    file_gcp = bucket.create_file(file.tempfile, file_name)

    # save gcp_link
    @control_document.update(gcp_link: file_gcp.public_url)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('control_document', partial: 'control_documents/control_document', locals: {control_document: @control_document})
      end
    end
  end

  def show
    bucket = retrieve_gcp_bucket
    filename = @control_document.gcp_link&.gsub('https://storage.googleapis.com/budgetlab-bucket/', '')
    file = bucket.file(filename)
    # Téléchargez le contenu du fichier PDF
    file_content = file.download.read
    send_data file_content, filename:, disposition: 'inline'
  end

  def destroy
    # Suppression du fichier dans GCS
    bucket = retrieve_gcp_bucket
    filename = @control_document.gcp_link&.gsub('https://storage.googleapis.com/budgetlab-bucket/', '')
    # Supprimez le fichier dans GCS en utilisant son chemin ou son nom
    bucket.file(filename)&.delete

    # Supprimez le document de la base de données
    @organisme = @control_document.organisme
    @control_document.destroy
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
    params.require(:control_document).permit(:name, :gcp_link, :user_id, :organisme_id, :signature_date)
  end

  def retrieve_gcp_bucket
    bucket_name = 'budgetlab-bucket'
    storage = Google::Cloud::Storage.new(project_id: 'apps-354210')
    storage.bucket(bucket_name)
  end

  def redirect_unless_admin
    redirect_to root_path and return unless @statut_user == '2B2O'
  end

  def set_organisme
    @organisme = Organisme.find(params[:organisme_id])
    redirect_to root_path and return unless @organisme
  end
end
