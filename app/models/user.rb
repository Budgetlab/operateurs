# frozen_string_literal: true

# Model User
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :modifications
  has_many :bureau_organismes,
           foreign_key: :bureau_id,
           class_name: 'Organisme'
  has_many :controleur_organismes,
           foreign_key: :controleur_id,
           class_name: 'Organisme'
  has_many :chiffres
  has_many :control_documents

  def self.import(file)
    User.where.not(statut: '2B2O').destroy_all
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

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "email", "encrypted_password", "id", "nom", "remember_created_at", "reset_password_sent_at", "reset_password_token", "statut", "updated_at"]
  end

  ransacker :nom, type: :string do
    Arel.sql("unaccent(users.\"nom\")")
  end
end
