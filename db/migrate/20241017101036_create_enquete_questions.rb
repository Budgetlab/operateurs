class CreateEnqueteQuestions < ActiveRecord::Migration[7.2]
  def change
    create_table :enquetes do |t|
      t.integer :annee, null: false

      t.timestamps
    end
    create_table :enquete_questions do |t|
      t.text :nom
      t.text :categorie
      t.integer :numero
      t.references :enquete, null: false, foreign_key: true

      t.timestamps
    end
  end
end
