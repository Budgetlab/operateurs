class AddCommentaireToModification < ActiveRecord::Migration[7.0]
  def change
    add_column :modifications, :commentaire, :string
  end
end
