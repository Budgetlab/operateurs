class RemoveForeignKeyConstraintFromOrganismes < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :organismes, column: :bureau_id
    remove_foreign_key :organismes, column: :ministere_id
  end
end
