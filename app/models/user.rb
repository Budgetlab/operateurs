# frozen_string_literal: true

# Model User
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable
  has_many :modifications
  has_many :bureau_organismes,
           foreign_key: :bureau_id,
           class_name: 'Organisme'
  has_many :controleur_organismes,
           foreign_key: :controleur_id,
           class_name: 'Organisme'
  has_many :chiffres
  has_many :control_documents
  has_many :objectifs_contrats, dependent: :destroy

  def self.import(file)
    data = Roo::Spreadsheet.open(file.path)
    headers = data.row(1) # get header row
    data.each_with_index do |row, idx|
      next if idx == 0 # skip header

      row_data = Hash[[headers, row].transpose]
      user = User.find_or_initialize_by(nom: row_data['nom'].to_s)
      user.email = "user#{idx.to_s}@finances.gouv.fr"
      user.statut = row_data['statut'].to_s
      user.nom = row_data['nom'].to_s
      user.password = row_data['Mot de passe'].to_s
      user.save
    end
  end

  def self.authentication_keys
    {statut: true, nom: false}
  end

  def self.ransackable_associations(auth_object = nil)
    ["bureau_organismes", "chiffres", "control_documents", "controleur_organismes", "modifications", "objectifs_contrats"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "current_sign_in_at", "current_sign_in_ip", "email", "encrypted_password", "id", "id_value", "last_sign_in_at", "last_sign_in_ip", "nom", "remember_created_at", "reset_password_sent_at", "reset_password_token", "sign_in_count", "statut", "updated_at"]
  end

  ransacker :nom, type: :string do
    Arel.sql("unaccent(users.\"nom\")")
  end

  def total_organisms(organisms_id)
    controleur_organismes.select { |organism| organisms_id.include?(organism.id) && organism.etat == 'Actif' }.size
  end

  def total_chiffres(organisms_id)
    chiffres.select { |chiffre| organisms_id.include?(chiffre.organisme_id) && chiffre.statut == 'valide' }.size
  end

  def total_bi(exercice_budgetaire, organisms_id)
    chiffres.select { |chiffre| organisms_id.include?(chiffre.organisme_id) && chiffre.statut == 'valide' && chiffre.type_budget == "Budget initial" && chiffre.exercice_budgetaire == exercice_budgetaire.to_i }.size
  end

  def total_cf(exercice_budgetaire, organisms_id)
    chiffres.select { |chiffre| organisms_id.include?(chiffre.organisme_id) && chiffre.statut == 'valide' && chiffre.type_budget == "Compte financier" && chiffre.exercice_budgetaire == exercice_budgetaire.to_i }.size
  end

  def total_br(exercice_budgetaire, organisms_id)
    chiffres.select { |chiffre| organisms_id.include?(chiffre.organisme_id) && chiffre.statut == 'valide' && chiffre.type_budget == "Budget rectificatif" && chiffre.exercice_budgetaire == exercice_budgetaire.to_i }.size
  end
end
