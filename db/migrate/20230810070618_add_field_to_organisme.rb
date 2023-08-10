class AddFieldToOrganisme < ActiveRecord::Migration[7.0]
  def change
    add_column :organismes, :arrete_interdiction_odac, :string
  end
end
