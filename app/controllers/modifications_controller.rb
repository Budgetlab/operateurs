# frozen_string_literal: true

# Controller Modifications
class ModificationsController < ApplicationController
  before_action :statut
  def index
    admin = User.find_by(nom: '2B2O')
    @modifications = @statut == 'Controleur' ? current_user.modifications.includes(:organisme).order(created_at: :desc) : Modification.where.not(user_id: admin.id).includes(:organisme).order(created_at: :desc)
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
    redirect_to root_path and return unless current_user.statut == '2B2O'

    champ = @modification.champ
    @organisme.update(champ => @modification.nouvelle_valeur)
    @operateur = @organisme.operateur
    @modifications = @organisme.modifications.includes(:user).order(created_at: :desc)
    modifications_classees(@modifications)
    redirect_to request.referer.presence || root_path, flash: { notice: 'modification' }
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
