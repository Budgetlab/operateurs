class RemoveChargesPersonnelInChiffres < ActiveRecord::Migration[7.0]
  def change
    remove_column :chiffres, :charges_personnel
  end
end
