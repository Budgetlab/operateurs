class CreateChiffres < ActiveRecord::Migration[7.0]
  def change
    create_table :chiffres do |t|
      t.references :organisme, null: false, foreign_key: true
      t.integer :exercice_budgetaire
      t.string :type_budget
      t.string :phase
      t.string :statut
      t.string :commentaire
      t.boolean :comptabilite_budgetaire
      t.boolean :operateur

      t.timestamps
    end
  end
end
