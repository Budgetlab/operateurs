class AddStatutToMissionsAndProgrammes < ActiveRecord::Migration[8.1]
  def change
    add_column :missions, :statut, :string, default: 'actif'
    add_column :programmes, :statut, :string, default: 'actif'
  end
end
