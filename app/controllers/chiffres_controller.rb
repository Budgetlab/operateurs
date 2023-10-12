# frozen_string_literal: true

# Controller Pages Chiffres
class ChiffresController < ApplicationController
  before_action :find_organisme, only: %i[index show_dates]
  def index
    @chiffres = @organisme.chiffres
    @date = Date.today.year
    liste_budgets(@date, @chiffres)
  end

  def show_dates
    @chiffres = @organisme.chiffres
    @date = params[:exercice_budgetaire]
    liste_budgets(@date, @chiffres)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('tabs', partial: 'chiffres/tabs')
        ]
      end
    end
  end

  def new
    redirect_to root_path and return unless @statut_user == 'Bureau Sectoriel' || @statut_user == 'Controleur'

    @chiffre = Chiffre.new
    @organismes = if @statut_user == 'Controleur'
                    current_user.controleur_organismes.where(statut: 'valide', etat: 'Actif')
                  else
                    current_user.bureau_organismes.where(statut: 'valide', etat: 'Actif')
                  end
  end

  def select_comptabilite
    comptabilite = Organisme.where(id: params[:organisme])&.first&.comptabilite_budgetaire
    comptabilite = comptabilite != 'Non' if comptabilite

    response = { comptabilite: comptabilite }
    render json: response
  end

  def select_exercice
    date = params[:exercice]
    operateur = Organisme.where(id: params[:organisme])&.first&.operateur if params[:organisme]
    operateur = case date.to_i
                when Date.today.year + 1
                  operateur&.operateur_nf
                when Date.today.year
                  operateur&.operateur
                when Date.today.year - 1
                  operateur&.operateur_n1
                else
                  false
                end

    response = { operateur: operateur || false }
    render json: response
  end

  def create
    @chiffre = Chiffre.new(chiffre_params)
    if @chiffre.save
      redirect_to edit_chiffre_path(@chiffre.id)
    else
      render :new
    end
  end

  def edit
    @chiffre = Chiffre.find(params[:id])
    @organisme = @chiffre.organisme
    @steps = @chiffre.comptabilite_budgetaire == true ? 6 : 5
  end

  def update
    @chiffre = Chiffre.find(params[:id])
  end

  def historique
    @organismes_id = if @statut_user == 'Controleur'
                       current_user.controleur_organismes.where(statut: 'valide', etat: 'Actif').pluck(:id)
                     elsif @statut_user == 'Bureau Sectoriel'
                       current_user.bureau_organismes.where(statut: 'valide', etat: 'Actif').pluck(:id)
                     else
                       Organisme.where(statut: 'valide', etat: 'Actif').pluck(:id)
                     end
    @chiffres = Chiffre.where(organisme_id: @organismes_id).includes(:organisme, :user)
  end

  def filterchiffres
    @chiffres = Chiffre.where(organisme_id: @organismes_id).includes(:organisme, :user)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('table_historique', partial: 'chiffres/table_historique', locals: { chiffres: @chiffres })
        ]
      end
    end
  end

  private

  def chiffre_params
    params.require(:chiffre).permit(:organisme_id, :type_budget, :exercice_budgetaire, :phase, :statut, :commentaire,
                                    :comptabilite_budgetaire, :operateur, :user_id)
  end

  def find_organisme
    @organisme = Organisme.find(params[:organisme_id])
  end

  def liste_budgets(exercice_budgetaire, chiffres)
    @budget_initial = filter_chiffres('Budget initial', exercice_budgetaire, chiffres)
    @budgets_rectificatifs = filter_chiffres('Budget rectificatif', exercice_budgetaire, chiffres)
    @compte_financier = filter_chiffres('Compte financier', exercice_budgetaire, chiffres)
  end

  def filter_chiffres(type_budget, exercice_budgetaire, chiffres)
    chiffres.select { |el| el.type_budget == type_budget && el.exercice_budgetaire == exercice_budgetaire }
  end
end
