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
    @liste_familles = ['Affaires étrangères', "Agences de l'Eau", 'Agriculture hors formation', 'ARS', 'Aucune', 'Autres écoles', 'Blanchisseries', 'CANCEROPOLES', 'CARIF OREF','CDAD', "Chambres d'agriculture", 'Cité des Métiers', 'CPP', 'CTI', "Écoles d'art et d'architecture", 'Écoles fonction publique / militaires', "Ecoles Françaises à l'Etranger", 'Écoles Normales, Centrales, Ingénieurs, Chimie et Techniques', 'Écoles vétérinaires et agro', 'Emploi / travail', 'EPAt', 'EPF et EPFA et 50 pas', 'FCIP', 'Financeurs', 'Financeurs Culture', 'GRADES', 'IEP', 'Immobilier', 'Instituts nationaux des jeunes sourds ou aveugles et éducation inclusive', "Maisons de l’emploi", 'Maisons des adolescents', 'Musées', 'Œuvres universitaires et scolaires', 'OPCO', 'Organismes de recherche', 'Parcs nationaux', 'Patrimoine', 'Ports, grands ports maritimes et terminaux de croisière', 'Santé et Sécurité sociale', 'Support enseignement supérieur', 'Théatres, Spectacles et Opéra', 'Universités' ]
    @liste_natures = ['API', 'Association', 'CPP', 'CTI', 'EP de Nouvelle-Calédonie', 'EP international', 'EP sui generis', 'EPA', 'EPCS', 'EPE', 'EPIC', 'EPSCP', 'EPST', 'établissement à caractère scientifique, technique et industriel', 'Fondation', 'GCS', 'GCSMS', 'GIE', 'GIP', 'OPCO', 'OSS', 'SCN', 'société']
    @liste_approbation = ['CBCM Armées', 'CBCM Culture', 'CBCM intérieur/ Outre-mer', 'CBCM MASS', 'CBCM MEN-MESRI', 'CBCM MINEFI', 'CBCM SPM', "Conseil de surveillance de l'agence", 'DB', 'DRFiP Auvergne-Rhône-Alpes', 'DRFiP Bourgogne-Franche-Comté', 'DRFiP Bretagne', 'DRFiP Centre Val de Loire', 'DRFiP Corse', 'DRFiP Grand-Est', 'DRFiP Guadeloupe', 'DRFiP Guyane', 'DRFiP Hauts-de-France', 'DRFiP IDF', 'DRFiP Martinique', 'DRFiP Mayotte', 'DRFiP Normandie', 'DRFiP Nouvelle Aquitaine', 'DRFiP Occitanie', 'DRFiP PACA', 'DRFiP Pays de la Loire', 'DRFiP Réunion',
                          'Mission agriculture forêt et pêche', 'Mission Aménagement des territoires, ville, logement Outre-mer', 'Mission Ecologie et développement durable', 'Mission Espace, armement et organismes divers des MEF', 'Mission Infrastructures de transports non ferroviaires', 'Mission Médias - Culture', 'Mission recherche appliquée et promotion de la qualité', "Recteur de région académique ou chancellier des universités ou ministre chargé de l'enseignement supérieur" ]
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
