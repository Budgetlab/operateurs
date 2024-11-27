class CreateObjectifsContrats < ActiveRecord::Migration[7.2]
  def change
    create_table :objectifs_contrats do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organisme, null: false, foreign_key: true
      t.string :nom
      t.integer :debut
      t.integer :fin

      t.timestamps
    end
  end
end
