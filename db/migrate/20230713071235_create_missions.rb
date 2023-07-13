class CreateMissions < ActiveRecord::Migration[7.0]
  def change
    create_table :missions do |t|
      t.string :nom
      t.references :programme, null: false, foreign_key: true

      t.timestamps
    end
  end
end
