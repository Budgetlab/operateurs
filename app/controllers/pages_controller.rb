# frozen_string_literal: true

# Controller Pages statiques
class PagesController < ApplicationController
  before_action :authenticate_user!
  def index; end
  def mentions_legales; end
  def accessibilite; end
  def donnees_personnelles; end
  def plan; end
end
