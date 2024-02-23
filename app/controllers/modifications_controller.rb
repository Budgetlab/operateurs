# frozen_string_literal: true

# Controller Modifications
class ModificationsController < ApplicationController
  before_action :statut
  def index
    @user_names = User.pluck(:id, :nom).to_h
    @organismes = Organisme.all.pluck(:id, :nom, :acronyme)
    organismes_ids = @organismes.map(&:first)
    modification_counts = @modifications.modifications_count_by_controller(organismes_ids)
    @modifications = []
    @totaux = []
    statuts = ['En attente', 'validée', 'refusée']
    statuts.each do |statut|
      modification_statut = filter_modification_counts(modification_counts, statut)
      @modifications << modification_statut
      @totaux << modification_statut.sum(&:modification_count)
    end
    @modifications_admin = Modification.where(user_id: current_user.id).includes(:organisme).order(created_at: :desc) if @statut_user == '2B2O'

  end

  def filter_modifications
    @user_names = User.pluck(:id, :nom).to_h
    @organismes = Organisme.all.pluck(:id, :nom, :acronyme)
    condition_filtre = params[:organisme] && !params[:organisme].blank?
    organismes_ids = condition_filtre ? params[:organisme].to_i : @organismes.map(&:first)
    modification_counts = @modifications.modifications_count_by_controller(organismes_ids)
    @modifications = []
    @totaux = []
    statuts = ['En attente', 'validée', 'refusée']
    statuts.each do |statut|
      modification_statut = filter_modification_counts(modification_counts, statut)
      @modifications << modification_statut
      @totaux << modification_statut.sum(&:modification_count)
    end
    @modifications_admin = Modification.where(user_id: current_user.id, organisme_id: organismes_ids).includes(:organisme).order(created_at: :desc) if @statut_user == '2B2O'
    respond_to do |format|
      format.turbo_stream do
        updates = []
        [0, 1, 2].each do |i|
          updates << turbo_stream.update("table_modifications_#{i}", partial: 'modifications/table_modifications_group', locals:  {modifications: @modifications[i], i: i, user_names: @user_names, organismes: @organismes} )
          updates << turbo_stream.update("total_modifications_#{i}", @totaux[i].to_s)
        end
        updates << turbo_stream.update('table_modifications', partial: 'modifications/table_modifications_admin', locals: { modifications: @modifications_admin })
        updates << turbo_stream.update('total_modifications_admin', @modifications_admin.length.to_s)
        render turbo_stream: updates
      end
    end
  end

  def open_modal
    @modification = Modification.find(params[:id])
    redirect_to request.referer.presence || root_path, flash: { notice: 'supprimée' } unless @modification
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('modal_refus', partial: 'modifications/motif_refus',
                                             locals: { modification: @modification })
        ]
      end
    end
  end

  def update
    @modification = Modification.find(params[:id])
    redirect_to root_path and return unless current_user.statut == '2B2O'

    if @modification
      @modification.update(modification_params)
      @organisme = @modification.organisme

      if @modification.statut == 'validée'
        champ = @modification.champ
        if champ == 'ministeres'
          selected_ministeres = @modification.nouvelle_valeur.gsub(/\[|\]/, '').split(',').map(&:to_i)
          @organisme.organisme_ministeres.destroy_all
          selected_ministeres.each do |ministere_id|
            @organisme.organisme_ministeres.create(ministere_id: ministere_id)
          end
        else
          @organisme.update(champ => @modification.nouvelle_valeur)
        end
        @message = 'validée'
      elsif @modification.statut == 'refusée'
        @message = 'refusée'
      end
    else
      @message = 'supprimée'
    end
    @operateur = @organisme.operateur
    modifications_organisme = @organisme.modifications.includes(:user).order(created_at: :desc)
    modifications_classees(modifications_organisme)
    redirect_to request.referer.presence || root_path, flash: { notice: @message }
  end

  def destroy
    @modification = Modification.find(params[:id])
    @message = @modification && @modification.statut == 'En attente' ? 'annulation' : 'non annulation'
    @modification.destroy if @modification && @modification.statut == 'En attente'
    redirect_to request.referer.presence || root_path, flash: { notice: @message }
  end

  private

  def modification_params
    params.require(:modification).permit(:user_id, :statut, :commentaire, :ancienne_valeur, :nouvelle_valeur, :nom, :champ, :organisme_id)
  end

  def modifications_classees(modifications)
    @modifications_valides = modifications.select { |modification| modification.statut == 'validée' }
    @modifications_rejetees = modifications.select { |modification| modification.statut == 'refusée' }
    @modifications_attente = modifications.select { |modification| modification.statut == 'En attente' }
  end

  def statut
    @statut = current_user.statut if current_user.statut == 'Controleur' || current_user.statut == '2B2O'
    redirect_to root_path if @statut.nil?
  end

  def filter_modification_counts(modification_counts, statut)
    modification_counts.select { |modification| modification.statut == statut }
  end

end
