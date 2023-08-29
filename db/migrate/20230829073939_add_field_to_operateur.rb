class AddFieldToOperateur < ActiveRecord::Migration[7.0]
  def change
    add_column :operateurs, :operateur_nf, :boolean
  end
end
