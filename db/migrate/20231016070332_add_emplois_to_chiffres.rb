class AddEmploisToChiffres < ActiveRecord::Migration[7.0]
  def change
    add_column :chiffres, :emplois_plafond, :float
    add_column :chiffres, :emplois_hors_plafond, :float
    add_column :chiffres, :emplois_total, :float
    add_column :chiffres, :emplois_plafond_rappel, :float
    add_column :chiffres, :emplois_plafond_prenotifie, :float
    add_column :chiffres, :emplois_schema, :float
    add_column :chiffres, :emplois_schema_prenotifie, :float
    add_column :chiffres, :emplois_non_remuneres, :float
    add_column :chiffres, :emplois_titulaires, :float
    add_column :chiffres, :emplois_titulaires_montant, :float
    add_column :chiffres, :emplois_contractuels, :float
    add_column :chiffres, :emplois_contractuels_montant, :float
    add_column :chiffres, :emplois_autre_entite, :float
    add_column :chiffres, :emplois_depenses_personnel, :float
    add_column :chiffres, :emplois_charges_personnel, :float
  end
end
