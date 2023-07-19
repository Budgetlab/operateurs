# frozen_string_literal: true

# Controller Modifications
class ModificationsController < ApplicationController
  def index
    admin = User.find_by(nom: '2B2O')
    @modifications = Modification.includes(:organisme).order(created_at: :desc) # .where.not(user_id: admin.id)
    modifications_classees(@modifications)
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
    @operateur = @organisme.operateur
    @modifications = @organisme.modifications.includes(:user).order(created_at: :desc)
    modifications_classees(@modifications)
    redirect_to request.referer.presence || root_path, flash: { notice: 'modification' }
  end

  private

  def modification_params
    params.require(:modification).permit(:user_id, :statut, :commentaire, :ancienne_valeur, :nouvelle_valeur, :organisme_id)
  end

  def modifications_classees(modifications)
    @modifications_valides = modifications.select { |modification| modification.statut == 'validée' }
    @modifications_rejetees = modifications.select { |modification| modification.statut == 'refusée' }
    @modifications_attente = modifications.select { |modification| modification.statut == 'En attente' }
  end

end
