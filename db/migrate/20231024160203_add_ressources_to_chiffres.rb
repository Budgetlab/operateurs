class AddRessourcesToChiffres < ActiveRecord::Migration[7.0]
  def change
    add_column :chiffres, :ressources_total, :float
  end
end
