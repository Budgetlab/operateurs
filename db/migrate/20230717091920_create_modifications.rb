class CreateModifications < ActiveRecord::Migration[7.0]
  def change
    create_table :modifications do |t|
      t.references :organisme, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :champ
      t.string :statut
      t.string :ancienne_valeur
      t.string :nouvelle_valeur

      t.timestamps
    end
  end
end
