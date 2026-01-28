# frozen_string_literal: true

# Controller Pages Missions
class MissionsController < ApplicationController
  before_action :authenticate_admin!, only: %i[index import_missions]
  def index
    @missions = Mission.all
  end

  def import_missions
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
