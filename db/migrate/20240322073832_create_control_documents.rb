class CreateControlDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :control_documents do |t|
      t.string :name
      t.string :gcp_link
      t.references :user, null: false, foreign_key: true
      t.references :organisme, null: false, foreign_key: true
      t.date :signature_date

      t.timestamps
    end
  end
end
