# frozen_string_literal: true

# Controller Pages Missions
class MissionsController < ApplicationController
  def index
    redirect_to root_path and return unless current_user.statut == '2B2O'

    @missions = Mission.all.pluck(:nom)
    @programmes = Programme.all.pluck(:nom)
  end

  def import_missions
    redirect_to root_path and return unless current_user.statut == '2B2O'

    Mission.import(params[:file])
    respond_to do |format|
      format.turbo_stream { redirect_to missions_path }
    end
  end

  def select_mission
    mission = !params[:programme].nil? && !params[:programme].blank? ? Mission.where(programme_id: params[:programme]).first : nil

    response = { mission: mission }
    render json: response
  end
end
