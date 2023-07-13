class CreateOperateurProgrammes < ActiveRecord::Migration[7.0]
  def change
    create_table :operateur_programmes do |t|
      t.references :operateur, null: false, foreign_key: true
      t.references :programme, null: false, foreign_key: true

      t.timestamps
    end
  end
end
