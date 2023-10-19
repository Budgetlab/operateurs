class AddAnalyseToChiffres < ActiveRecord::Migration[7.0]
  def change
    add_column :chiffres, :commentaire_annexe, :string
    add_column :chiffres, :capacite_autofinancement, :float
    add_column :chiffres, :fonds_roulement_final, :float
    add_column :chiffres, :fonds_roulement_variation, :float
    add_column :chiffres, :fonds_roulement_inital, :float
    add_column :chiffres, :fonds_roulement_besoin_initial, :float
    add_column :chiffres, :fonds_roulement_besoin_final, :float
    add_column :chiffres, :risque_insolvabilite, :string
  end
end
