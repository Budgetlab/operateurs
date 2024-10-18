class CreateEnqueteReponses < ActiveRecord::Migration[7.2]
  def change
    create_table :enquete_reponses do |t|
      t.references :organisme, null: false, foreign_key: true
      t.references :enquete, null: false, foreign_key: true
      t.jsonb :reponses, default: {} # Stocker les réponses sous forme de JSONB

      t.timestamps
    end
  end
end
