# frozen_string_literal: true

# Controller Modifications
class ModificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_controleur

  # page gestion des modifications
  def index
    @user_names = User.pluck(:id, :nom).to_h
    organismes = liste_organisme
    # liste organismes barre de recherche
    @organismes = organismes.pluck(:id, :nom, :acronyme)
    organismes_ids = @organismes.map(&:first)
    # classification des modifications par statut et controleur
    @groupes_modifications = classification_modifications(organismes_ids) # [modifications, total]
    # modification 2B2O
    user_admin = User.find_by(nom: '2B2O')
    @modifications_admin = user_admin.modifications.where(organisme_id: organismes_ids).includes(:organisme).order(created_at: :desc)

  end

  # fonction pour filtrer les résultats des modifications en fonction de l'organisme choisit
  def filter_modifications
    @user_names = User.pluck(:id, :nom).to_h
    organismes = liste_organisme
    @organismes = organismes.pluck(:id, :nom, :acronyme)
    condition_filtre = params[:organisme] && !params[:organisme].blank?
    organismes_ids = condition_filtre ? params[:organisme].to_i : @organismes.map(&:first)
    # classification des modifications par statut et controleur
    @groupes_modifications = classification_modifications(organismes_ids) # [modifications, total]
    # modification 2B2O
    user_admin = User.find_by(nom: '2B2O')
    @modifications_admin = user_admin.modifications.where(organisme_id: organismes_ids).includes(:organisme).order(created_at: :desc)
    respond_to do |format|
      format.turbo_stream do
        updates = []
        [0, 1, 2].each do |i|
          updates << turbo_stream.update("table_modifications_#{i}", partial: 'modifications/table_modifications_group', locals:  {modifications: @groupes_modifications[0][i], i: i, user_names: @user_names, organismes: @organismes} )
          updates << turbo_stream.update("total_modifications_#{i}", @groupes_modifications[1][i].to_s)
        end
        updates << turbo_stream.update('table_modifications', partial: 'modifications/table_modifications_admin', locals: { modifications: @modifications_admin })
        updates << turbo_stream.update('total_modifications_admin', @modifications_admin.length.to_s)
        render turbo_stream: updates
      end
    end
  end

  # fonction pour ouvrir le modal pour commenter refus
  def open_modal
    modification = Modification.find_by(id: params[:id])
    redirect_to request.referer.presence || root_path, flash: { notice: 'supprimée' } unless modification
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('modal_refus', partial: 'modifications/motif_refus',
                                             locals: { modification: modification })
        ]
      end
    end
  end

  # fonction pour mettre à jour le statut de la modification par 2B2O et l'organisme
  def update
    redirect_unless_admin
    modification = Modification.find_by(id: params[:id])
    modification&.update(modification_params)
    message = modification ? modification.statut : 'supprimée'
    update_champ_organisme(modification) if modification&.statut == 'validée'
    redirect_to request.referer.presence || root_path, flash: { notice: message }
  end

  # fonction pour annuler une demande de modification en attente de validation
  def destroy
    modification = Modification.find_by(id: params[:id], statut: 'En attente')
    message = modification ? 'annulation' : 'non annulation'
    modification&.destroy
    redirect_to request.referer.presence || root_path, flash: { notice: message }
  end

  private

  def modification_params
    params.require(:modification).permit(:user_id, :statut, :commentaire, :ancienne_valeur, :nouvelle_valeur, :nom, :champ, :organisme_id)
  end

  def redirect_unless_controleur
    redirect_to root_path unless @statut_user == '2B2O' || @statut_user == 'Controleur'
  end

  def redirect_unless_admin
    redirect_to root_path and return unless @statut_user == '2B2O'
  end

  def classification_modifications(organismes_ids)
    modifications_statut = []
    totaux = []
    modification_counts = @modifications.modifications_count_by_controller(organismes_ids)
    statuts = ['En attente', 'validée', 'refusée']
    statuts.each do |statut|
      modification_statut = filter_modification_counts(modification_counts, statut)
      modifications_statut << modification_statut
      totaux << modification_statut.sum(&:modification_count)
    end
    [modifications_statut, totaux]
  end

  def filter_modification_counts(modification_counts, statut)
    modification_counts.select { |modification| modification.statut == statut }
  end

  def liste_organisme
    case @statut_user
    when '2B2O'
      Organisme.all
    when 'Controleur'
      current_user.controleur_organismes.where(statut: 'valide')
    when 'Bureau Sectoriel'
      current_user.bureau_organismes.where(statut: 'valide')
    end
  end

  # fonction pour mettre à jour le champ de l'organisme concerné si modification validée
  def update_champ_organisme(modification)
    champ = modification.champ
    organisme = modification.organisme
    if champ == 'ministeres' # met à jour la liste des ministère de co-tutelles sous forme de tableau
      organisme.organisme_ministeres.destroy_all
      selected_ministeres = modification.nouvelle_valeur.gsub(/\[|\]/, '').split(',').map(&:to_i)
      selected_ministeres.each do |ministere_id|
        organisme.organisme_ministeres.create(ministere_id: ministere_id)
      end
    else
      organisme.update(champ => modification.nouvelle_valeur)
    end
  end

end
