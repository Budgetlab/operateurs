class CreateOperateurs < ActiveRecord::Migration[7.0]
  def change
    create_table :operateurs do |t|
      t.references :organisme, null: false, foreign_key: true
      t.boolean :operateur_n
      t.boolean :operateur_n1
      t.boolean :operateur_n2
      t.boolean :presence_categorie
      t.string :nom_categorie
      t.references :mission, null: false, foreign_key: true
      t.references :programme, null: false, foreign_key: true

      t.timestamps
    end
  end
end
