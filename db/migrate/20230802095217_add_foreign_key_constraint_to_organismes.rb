class AddForeignKeyConstraintToOrganismes < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :organismes, :users, column: 'bureau_id', optional: true
    add_foreign_key :organismes, :ministeres, column: 'ministere_id', optional: true
  end
end
