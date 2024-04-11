# frozen_string_literal: true

# Controller Users
class UsersController < ApplicationController
  protect_from_forgery with: :null_session
  def index
    # redirect_to root_path unless current_user && current_user.statut != '2B2O'
    @noms_users = User.all.pluck(:nom)
    Organisme.all.each do |organisme|
      if organisme.famille&.last == ' '
        organisme.famille = organisme.famille.rstrip
        organisme.save
      end
      if organisme.famille == 'Cité des métiers'
        organisme.famille = 'Cité des Métiers'
        organisme.save
      elsif organisme.famille == "Soutien à l’enseignement supérieur et à la recherche "
        organisme.famille = 'Soutien à l’enseignement supérieur et à la recherche'
        organisme.save
      end
      if organisme.arrete_interdiction_odac == "Annexe1"
        organisme.arrete_interdiction_odac = 'Annexe 1'
        organisme.save
      elsif organisme.arrete_interdiction_odac == "Annexe2"
        organisme.arrete_interdiction_odac = 'Annexe 2'
        organisme.save
      end
      if organisme.nature_controle == 'Contrôle Economique et Financier'
        organisme.nature_controle = 'Contrôle Économique et Financier'
        organisme.save
      end

    end
    @familles = Organisme.all.pluck(:famille).uniq
    @natures = Organisme.all.pluck(:nature).uniq
  end

  def import
    User.import(params[:file])
    respond_to do |format|
      format.turbo_stream { redirect_to users_path }
    end
  end

  def select_nom
    noms = !params[:statut].nil? && !params[:statut].blank? ? User.where(statut: params[:statut]).order(nom: :asc).pluck(:nom) : nil
    response = { noms: noms }
    render json: response
  end
end
