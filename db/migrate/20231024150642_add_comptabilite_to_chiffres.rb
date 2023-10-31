class AddComptabiliteToChiffres < ActiveRecord::Migration[7.0]
  def change
    add_column :chiffres, :charges_personnel, :float
    add_column :chiffres, :charges_fonctionnement, :float
    add_column :chiffres, :charges_intervention, :float
    add_column :chiffres, :charges_non_decaissables, :float
    add_column :chiffres, :produits_subventions_etat, :float
    add_column :chiffres, :produits_fiscalite_affectee, :float
    add_column :chiffres, :produits_subventions_autres, :float
    add_column :chiffres, :produits_autres, :float
    add_column :chiffres, :produits_non_encaissables, :float
    add_column :chiffres, :emplois_cout_total, :float
    add_column :chiffres, :emplois_cout_investissements, :float
    add_column :chiffres, :ressources_financement_etat, :float
    add_column :chiffres, :ressources_autres, :float
    add_column :chiffres, :decaissements_emprunts, :float
    add_column :chiffres, :encaissements_emprunts, :float
    add_column :chiffres, :decaissements_operations, :float
    add_column :chiffres, :encaissements_operations, :float
    add_column :chiffres, :decaissements_autres, :float
    add_column :chiffres, :encaissements_autres, :float
    remove_column :chiffres, :fonds_roulement_inital
    remove_column :chiffres, :fonds_roulement_besoin_initial
  end
end
