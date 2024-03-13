# frozen_string_literal: true

# Controller Pages statiques
class PagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_famille, only: [:index]
  def index
    organismes_all = Organisme.all
    # liste des organismes accessibles depuis la barre de recherche en fonction du profil
    search_organismes = fetch_organisms_famille_extended(organismes_all)
    @search_organismes = search_organismes&.pluck(:id, :nom, :acronyme)&.sort_by { |organisme| organisme[1] }
    # derniers organismes modifiés
    organismes_user = filtre_organismes_user(organismes_all)
    @organismes_last = organismes_user ? organismes_user.order(updated_at: :desc).limit(6).pluck(:id, :nom, :acronyme, :updated_at, :nature, :famille, :etat, :statut) : []
  end

  def mentions_legales; end
  def accessibilite; end
  def donnees_personnelles; end
  def plan; end

  def documents
    redirect_to root_path and return unless @statut_user == '2B2O'

    @array_controleurs_liens = User.where(statut: 'Controleur').left_joins(:controleur_organismes).group('users.id').select('users.nom, COALESCE(COUNT(organismes.document_controle_lien), 0) AS nombre_liens').order('users.nom ASC')
  end

  def documents_controleur
    redirect_to root_path and return unless @statut_user == '2B2O'

    @user = User.find_by(nom: params[:user])
    redirect_to documents_path and return unless @user

    @documents_controle = @user.controleur_organismes.where.not(document_controle_lien: nil).pluck(:id, :nom, :acronyme, :document_controle_lien, :document_controle_date)
  end

  private

  def set_famille
    if @statut_user == 'Controleur'
      @familles = current_user.controleur_organismes.pluck(:famille).uniq.reject { |element| element == 'Aucune' }
      @familles += ['Universités'] if current_user.nom == 'CBCM MEN-MESRI'
    elsif @statut_user == 'Bureau Sectoriel'
      @familles = current_user.bureau_organismes.pluck(:famille).uniq.reject { |element| element == 'Aucune' }
    end
  end

  # filtre édition + lecture :récuperer les organismes qui lui appartiennent + ceux de la même famille (excluant aucune)
  # (attention si on ne prend que ceux des familles en commune on oublie les siens avec famille aucune)
  def fetch_organisms_famille_extended(organismes_all)
    case @statut_user
    when '2B2O'
      organismes_all
    when 'Controleur'
      organismes_all.where(statut: 'valide').select { |organisme| organisme.controleur_id == current_user.id || @familles.include?(organisme.famille) }
    when 'Bureau Sectoriel'
      organismes_all.where(statut: 'valide').select { |organisme| organisme.bureau_id == current_user.id || @familles.include?(organisme.famille) }
    end
  end

  # filtrer sur uniquement les siens en édition
  def filtre_organismes_user(organismes_all)
    case @statut_user
    when '2B2O'
      organismes_all
    when 'Controleur'
      organismes_all.where(statut: 'valide', controleur_id: current_user.id )
    when 'Bureau Sectoriel'
      organismes_all.where(statut: 'valide', bureau_id: current_user.id )
    end
  end

end
