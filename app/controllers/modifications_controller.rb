# frozen_string_literal: true

# Controller Modifications
class ModificationsController < ApplicationController
  before_action :statut
  def index
    @modification_counts = @modifications.modifications_count_by_controller
    @modification_counts_valides = @modification_counts.select { |modification| modification.statut == 'validée' }
    @modification_counts_refus = @modification_counts.select { |modification| modification.statut == 'refusée' }
    @modification_counts_attente = @modification_counts.select { |modification| modification.statut == 'En attente' }
    @total_valides = @modification_counts_valides.sum { |modification| modification.modification_count }
    @total_refus = @modification_counts_refus.sum { |modification| modification.modification_count }
  end

  def open_modal
    @modification = Modification.find(params[:id])
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
    @modification.update(modification_params)
    @organisme = @modification.organisme
    redirect_to root_path and return unless current_user.statut == '2B2O'

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
    @operateur = @organisme.operateur
    @modifications_organisme = @organisme.modifications.includes(:user).order(created_at: :desc)
    modifications_classees(@modifications_organisme)
    redirect_to request.referer.presence || root_path, flash: { notice: 'modification' }
  end

  def destroy
    @modification = Modification.find(params[:id]).destroy
    redirect_to request.referer.presence || root_path
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

end
