class UpdateComptabiliteBudgetaireValues < ActiveRecord::Migration[8.1]
  def up
    # Mettre à jour tous les organismes avec "Oui mais adaptée" vers "Oui"
    Organisme.where(comptabilite_budgetaire: 'Oui mais adaptée').update_all(comptabilite_budgetaire: 'Oui')
    puts "✓ #{Organisme.where(comptabilite_budgetaire: 'Oui mais adaptée').count} organismes mis à jour"
  end

  def down
    # Ne pas annuler cette migration car nous perdons l'information
    raise ActiveRecord::IrreversibleMigration
  end
end
