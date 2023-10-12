class AddUserToChiffres < ActiveRecord::Migration[7.0]
  def change
    add_reference :chiffres, :user, null: false, foreign_key: true
  end
end
