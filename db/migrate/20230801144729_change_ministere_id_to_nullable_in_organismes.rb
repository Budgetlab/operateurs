class ChangeMinistereIdToNullableInOrganismes < ActiveRecord::Migration[7.0]
  def change
    change_column_null :organismes, :ministere_id, true
  end
end
