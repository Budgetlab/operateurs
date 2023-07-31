class CreateMinisteres < ActiveRecord::Migration[7.0]
  def change
    create_table :ministeres do |t|
      t.string :nom

      t.timestamps
    end
  end
end
