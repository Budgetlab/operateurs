class AddMinistereIdToOrganismes < ActiveRecord::Migration[7.0]
  def change
    add_reference :organismes, :ministere, null: true, foreign_key: true
  end
end
