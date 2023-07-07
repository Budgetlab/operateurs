class CreateOrganismeRattachements < ActiveRecord::Migration[7.0]
  def change
    create_table :organisme_rattachements do |t|
      t.references :organisme, null: false, foreign_key: true
      t.references :organisme_destination, null: false, foreign_key: { to_table: :organismes }

      t.timestamps
    end
  end
end
