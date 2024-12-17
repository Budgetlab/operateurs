class UpdateFieldEnqueteOrganisme < ActiveRecord::Migration[7.2]
  def change
    remove_column :organismes, :document_controle_lien
    remove_column :organismes, :document_controle_date
    remove_column :enquete_questions, :categorie
    Modification.where(champ: "document_controle_lien").destroy_all
    Modification.where(champ: "document_controle_date").destroy_all
  end
end
