class RemoveGcpLinkInControlDocuments < ActiveRecord::Migration[7.1]
  def change
    remove_column :control_documents, :gcp_link
  end
end
