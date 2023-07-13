class CreateProgrammes < ActiveRecord::Migration[7.0]
  def change
    create_table :programmes do |t|
      t.integer :numero
      t.string :nom

      t.timestamps
    end
  end
end
