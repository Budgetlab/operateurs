class AddCreditsToChiffres < ActiveRecord::Migration[7.0]
  def change
    add_column :chiffres, :credits_ae_total, :float
    add_column :chiffres, :credits_ae_fonctionnement, :float
    add_column :chiffres, :credits_ae_intervention, :float
    add_column :chiffres, :credits_ae_investissement, :float
    add_column :chiffres, :credits_cp_total, :float
    add_column :chiffres, :credits_cp_fonctionnement, :float
    add_column :chiffres, :credits_cp_intervention, :float
    add_column :chiffres, :credits_cp_investissement, :float
    add_column :chiffres, :credits_cp_operations, :float
    add_column :chiffres, :credits_cp_recettes_flechees, :float
    add_column :chiffres, :credits_subvention_sp, :float
    add_column :chiffres, :credits_subvention_investissement_globalisee, :float
    add_column :chiffres, :credits_subvention_investissement_flechee, :float
    add_column :chiffres, :credits_financements_etat_autres, :float
    add_column :chiffres, :credits_financements_etat_fleches, :float
    add_column :chiffres, :credits_fiscalite_affectee, :float
    add_column :chiffres, :credits_financements_publics_autres, :float
    add_column :chiffres, :credits_financements_publics_fleches, :float
    add_column :chiffres, :credits_recettes_propres_globalisees, :float
    add_column :chiffres, :credits_recettes_propres_flechees, :float
    add_column :chiffres, :credits_restes_a_payer, :float
  end
end
