class AddNomToModification < ActiveRecord::Migration[7.0]
  def change
    add_column :modifications, :nom, :string
  end
end
