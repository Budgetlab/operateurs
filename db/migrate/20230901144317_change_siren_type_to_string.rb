class ChangeSirenTypeToString < ActiveRecord::Migration[7.0]
  def change
    change_column :organismes, :siren, :string
  end
end
