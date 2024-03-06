# frozen_string_literal: true

# Controller Application
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  rescue_from ActiveRecord::RecordNotFound do
    flash[:warning] = 'Resource not found.'
    redirect_back_or root_path
  end
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_global_variable
  before_action :set_modifications
  def redirect_back_or(path)
    redirect_to request.referer || path
  end
  helper_method :resource_name, :resource, :devise_mapping, :resource_class
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def resource_class
    User
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def set_global_variable
    @liste_nom_users = User.where(statut: 'Controleur').pluck(:nom)
    @liste_nom_ministeres = Ministere.all.order(nom: :asc).pluck(:nom)
    @liste_familles = ['Affaires étrangères', "Agences de l'Eau", 'Agriculture hors formation', 'ARS', 'Aucune', 'Autres écoles', 'Blanchisseries', 'CANCEROPOLES', 'CARIF OREF','CDAD', "Chambres d'agriculture", 'Cité des Métiers', 'CPP', 'CTI', "Écoles d'art et d'architecture", 'Écoles fonction publique / militaires', "Ecoles Françaises à l'Etranger", 'Écoles Normales, Centrales, Ingénieurs, Chimie et Techniques', 'Écoles vétérinaires et agro', 'Emploi / travail', 'EPF et EPFA et 50 pas', 'FCIP', 'Financeurs', 'Financeurs Culture', 'GRADES', 'IEP', 'Immobilier', 'Instituts nationaux des jeunes sourds ou aveugles et éducation inclusive', "Maisons de l’emploi", 'Maisons des adolescents', 'Musées', 'Œuvres universitaires et scolaires', 'OPCO', 'Organismes de recherche', 'Parcs nationaux', 'Patrimoine', 'Ports, grands ports maritimes et terminaux de croisière', 'Santé et Sécurité sociale', 'Soutien à l’enseignement supérieur et à la recherche', 'Théatres, Spectacles et Opéra', 'Universités' ]
    @liste_natures = ['API', 'Association', 'CPP', 'CTI', 'EP de Nouvelle-Calédonie', 'EP international', 'EP sui generis', 'EPA', 'EPCS', 'EPE', 'EPIC', 'EPSCP', 'EPST', 'Fondation', 'GIE', 'GIP', 'OPCO', 'OSS', 'Société']
    @liste_approbation = @liste_nom_users + ['DB', 'Ministre de la Santé',"Recteur de région académique ou chancellier des universités ou ministre chargé de l'enseignement supérieur", 'Autres' ]
    @liste_approbation = @liste_approbation.sort + @liste_nom_ministeres
    @liste_autorite_controle = @liste_nom_users + ['DDFiP Alpes-Maritimes','DDFIP Calvados','DDFiP Cher', 'DDFiP Doubs', 'DDFiP Essonne', 'DDFiP Eure et Loir', 'DDFiP Gard', 'DDFiP Haute-Corse', 'DDFiP Haute-Marne', 'DDFiP Hautes-Pyrénées', 'DDFiP Haute-Vienne', 'DDFiP Hauts de Seine', 'DDFiP Hérault', 'DDFiP Isère', 'DDFiP Jura', 'DDFiP Meuse', 'DDFIP Moselle', 'DDFiP Nièvre', 'DDFiP Oise', 'DDFiP Puy de Dôme', 'DDFiP Saône et Loire', 'DDFiP Somme', 'DDFiP Tarn et Garonne', "DDFiP Val d'Oise",'DDFiP Var', 'DDFiP Vienne','DDFiP Yvelines', 'Recteur', 'Autre']
    @liste_autorite_controle = @liste_autorite_controle.sort
    @liste_fonctions_admin_db = ['Directeur/Directrice du budget', 'Sous-directeur/Sous-directrice DB', 'Adjoint/e au sous-directeur/sous-directrice DB', 'Chef/fe de bureau', 'Adjoint/e au chef de bureau', 'Contrôleur/e', 'Chef/fe de service', 'Autre']
    @liste_autorites = ["Agences de l'eau", 'ARS - Agences régionales de santé', 'Associations de coordination technique agricole et des industries agroalimentaires', "Autres opérateurs d'enseignement supérieur et de recherche", "Communautés d'universités et d'établissements", "Ecoles d'architecture - Ecoles nationales supérieures d'architecture", "Ecoles d'art en Région", "Ecoles d'enseignement supérieur agricole et vétérinaire", "Ecoles et formations d'ingénieurs", 'Ecoles nationales des sports', 'Groupe Mines Télécom', "IRA - Instituts régionaux d'administration", "Opérateurs de soutien à l'enseignement supérieur et à la recherche", 'Parcs nationaux', 'Réseau des œuvres universitaires et scolaires', 'Universités et assimilés']
  end

  def set_modifications
    return unless current_user

    @statut_user = current_user.statut
    @modifications = @statut_user == '2B2O' ? Modification.where.not(user_id: current_user.id).includes(:organisme) : current_user.modifications.includes(:organisme)
    @modifications_attente = @modifications.select { |modification| modification.statut == 'En attente' }
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email statut nom password password_confirmation])
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[statut password nom])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[email password password_confirmation statut nom])
  end
end
