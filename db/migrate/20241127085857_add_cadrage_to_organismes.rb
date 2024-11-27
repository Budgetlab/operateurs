class AddCadrageToOrganismes < ActiveRecord::Migration[7.2]
  def up
    add_column :organismes, :taux_cadrage_n, :float
    add_column :organismes, :taux_cadrage_n1, :float
  end

  def down
    remove_column :organismes, :taux_cadrage_n
    remove_column :organismes, :taux_cadrage_n1
  end
end
