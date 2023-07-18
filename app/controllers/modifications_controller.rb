# frozen_string_literal: true

# Controller Modifications
class ModificationsController < ApplicationController
  def index
    @modifications = Modification.all.order(created_at: :desc)
  end
  def update
    @modification = Modification.find(params[:id])
    @organisme = @modification.organisme
    @modification.update(statut: params[:statut])
    @operateur = @organisme.operateur
    @modifications = @organisme.modifications
    @modifications_valides = @modifications.select { |modification| modification.statut == 'validée' }
    @modifications_rejetees = @modifications.select { |modification| modification.statut == 'refusée' }
    @modifications_attente = @modifications.select { |modification| modification.statut == 'En attente' }
    redirect_to organisme_path(@organisme)
  end

end
