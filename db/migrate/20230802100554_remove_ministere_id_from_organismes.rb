class RemoveMinistereIdFromOrganismes < ActiveRecord::Migration[7.0]
  def change
    remove_column :organismes, :ministere_id
  end
end
