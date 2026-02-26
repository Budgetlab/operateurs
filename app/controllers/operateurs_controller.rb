# frozen_string_literal: true

# Controller Pages operateurs
class OperateursController < ApplicationController
  before_action :authenticate_admin!
  def index
    @operateurs = Operateur.includes(:organisme, :mission, :programme).all
  end

  def deactivate
    @operateur = Operateur.find(params[:id])
    annee_fin = params[:annee_fin].to_i
    annee_min = @operateur.annees.max || Date.today.year
    if annee_fin >= annee_min
      @operateur.desactiver!(annee_fin)
      redirect_to operateurs_path, flash: { notice: "#{@operateur.organisme.nom} est maintenant inactif." }
    else
      redirect_to operateurs_path, flash: { alert: "L'année de fin ne peut pas être antérieure à #{annee_min}." }
    end
  end

  def new
    @organisme = Organisme.find(params[:organisme_id])
    @operateur = Operateur.new
    @programmes = Programme.all.order(numero: :asc)
    @liste_operateur = @operateur.operateur_programmes.pluck(:programme_id)
  end
  def create
    @organisme = Organisme.find(params[:operateur][:organisme_id])
    programmes_to_link = params[:operateur].delete(:programmes)

    if params[:operateur][:operateur_actif] == 'false'
      @organisme.update!(operateur_actif: false)
      return redirect_to organisme_path(@organisme)
    end

    @operateur = Operateur.new(operateur_params)
    annees = build_annees_from_periodes(params[:periodes])
    annees = [Date.today.year] if annees.empty?
    is_active = open_periode?(params[:periodes])

    if @operateur.save
      @operateur.update!(annees: annees)
      @organisme.update!(operateur_actif: is_active)
      update_operateur_programmes(programmes_to_link)
    end
    redirect_to organisme_path(@organisme)
  end

  def edit
    @organisme = Organisme.find(params[:organisme_id])
    @operateur = Operateur.find(params[:id])
    @programmes = Programme.all.order(numero: :asc)
    @liste_operateur = @operateur.operateur_programmes.pluck(:programme_id)
  end

  def update
    @organisme = Organisme.find(params[:operateur][:organisme_id])
    @operateur = Operateur.find(params[:id])
    programmes_to_link = params[:operateur].delete(:programmes)

    if params[:operateur][:operateur_actif] == 'false'
      @operateur.destroy
      @organisme.update!(operateur_actif: false)
      return redirect_to organisme_path(@organisme)
    end

    annees = build_annees_from_periodes(params[:periodes])
    annees = [Date.today.year] if annees.empty?
    is_active = open_periode?(params[:periodes])

    @operateur.update(operateur_params.merge(annees: annees))
    @organisme.update!(operateur_actif: is_active)
    update_operateur_programmes(programmes_to_link)
    redirect_to organisme_path(@organisme)
  end

  def import
    file = params[:file]
    Operateur.import(file) if file.present?
    respond_to do |format|
      format.turbo_stream { redirect_to operateurs_path }
    end
  end

  private

  def operateur_params
    params.require(:operateur).permit(:organisme_id, :presence_categorie,
                                      :nom_categorie, :mission_id, :programme_id)
  end

  # Builds a flat sorted array of years from submitted periodes.
  # Each periode has de: (required) and optionally a: (end year).
  # If a: is absent, the range is open-ended (active period: only de is stored).
  def build_annees_from_periodes(periodes_param)
    return [] if periodes_param.blank?

    annees = []
    periodes_param.each do |_i, p|
      de = p[:de].to_i
      next if de.zero?

      if p[:a].present?
        a = p[:a].to_i
        annees += (de..a).to_a if a >= de
      else
        annees << de
      end
    end
    annees.uniq.sort
  end

  # Returns true if any submitted periode has no end year (open-ended = currently active).
  # Falls back to true when no periodes are submitted (defaulting to current year as open period).
  def open_periode?(periodes_param)
    return true if periodes_param.blank?

    periodes_param.values.any? { |p| p[:de].present? && p[:a].blank? }
  end

  def update_operateur_programmes(programmes_to_link)
    if programmes_to_link && programmes_to_link.map(&:to_i).reject { |element| element == 0 } != @operateur.operateur_programmes.pluck(:programme_id)
      @operateur.operateur_programmes.destroy_all
      selected_programmes = programmes_to_link || []
      selected_programmes.map(&:to_i).reject { |element| element == 0 }.each do |programme_id|
        @operateur.operateur_programmes.create(programme_id: programme_id)
      end
    end
  end

end
