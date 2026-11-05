class UpdateRisqueInsolvabiliteValues < ActiveRecord::Migration[8.1]
  def up
    # « Situation saine » et « Situation saine a priori mais à surveiller » sont conservées telles quelles.
    # Seules les deux valeurs de risque sont regroupées vers « Risque d’insoutenabilité ».
    risques = ['Risque d’insoutenabilité à moyen terme', 'Risque d’insoutenabilité élevé']

    risques_count = Chiffre.where(risque_insolvabilite: risques).update_all(risque_insolvabilite: 'Risque d’insoutenabilité')

    puts "✓ #{risques_count} chiffres → « Risque d’insoutenabilité »"
  end

  def down
    # Ne pas annuler cette migration car nous perdons l'information
    raise ActiveRecord::IrreversibleMigration
  end
end
