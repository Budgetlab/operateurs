class CreateOrganismeMinisteres < ActiveRecord::Migration[7.0]
  def change
    create_table :organisme_ministeres do |t|
      t.references :organisme, null: false, foreign_key: true
      t.references :ministere, null: false, foreign_key: true

      t.timestamps
    end
  end
end
