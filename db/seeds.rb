# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
organisme = Organisme.where(etat: "Actif").first
annees = [2022, 2023, 2024]
annees.each do |annee|
  ["Budget initial", "Budget rectificatif","Compte financier"].each do |type_budget|
    organisme.chiffres.create!(
      exercice_budgetaire: annee,
      type_budget: type_budget,
      phase: 'CA',
      statut: 'valide',
      comptabilite_budgetaire: true,
      operateur: true,
      user_id: organisme.controleur.id,
      emplois_plafond: rand(1..100),
      emplois_hors_plafond: rand(1..100),
      emplois_total: rand(1..100),
      emplois_plafond_rappel: rand(1..100),
      emplois_plafond_prenotifie: rand(1..100),
      emplois_schema: rand(1..100),
      emplois_schema_prenotifie: rand(1..100),
      emplois_non_remuneres: rand(1..100),
      emplois_titulaires: rand(1..100),
      emplois_titulaires_montant: rand(1..100),
      emplois_contractuels: rand(1..100),
      emplois_contractuels_montant: rand(1..100),
      emplois_autre_entite: rand(1..100),
      emplois_depenses_personnel: rand(1..100),
      emplois_charges_personnel: rand(1..100),
      credits_ae_total: rand(1..100),
      credits_ae_fonctionnement: rand(1..100),
      credits_ae_intervention: rand(1..100),
      credits_ae_investissement: rand(1..100),
      credits_cp_total: rand(1..100),
      credits_cp_fonctionnement: rand(1..100),
      credits_cp_intervention: rand(1..100),
      credits_cp_investissement: rand(1..100),
      credits_cp_operations: rand(1..100),
      credits_cp_recettes_flechees: rand(1..100),
      credits_subvention_sp: rand(1..100),
      credits_subvention_investissement_globalisee: rand(1..100),
      credits_subvention_investissement_flechee: rand(1..100),
      credits_financements_etat_autres: rand(1..100),
      credits_financements_etat_fleches: rand(1..100),
      credits_fiscalite_affectee: rand(1..100),
      credits_financements_publics_autres: rand(1..100),
      credits_financements_publics_fleches: rand(1..100),
      credits_recettes_propres_globalisees: rand(1..100),
      credits_recettes_propres_flechees: rand(1..100),
      credits_restes_a_payer: rand(1..100),
      tresorerie_finale_flechee: rand(1..100),
      tresorerie_finale_non_flechee: rand(1..100),
      tresorerie_finale: rand(1..100),
      tresorerie_variation: rand(1..100),
      tresorerie_variation_flechee: rand(1..100),
      tresorerie_variation_non_flechee: rand(1..100),
      tresorerie_min: rand(1..100),
      tresorerie_max: rand(1..100),
      commentaire_annexe: 'This is a seed comment', # As this is a string type
      capacite_autofinancement: rand(1..100),
      fonds_roulement_final: rand(1..100),
      fonds_roulement_variation: rand(1..100),
      fonds_roulement_besoin_final: rand(1..100),
      risque_insolvabilite: 'This is a seed comment', # As this is a string type
      charges_fonctionnement: rand(1..100),
      charges_intervention: rand(1..100),
      charges_non_decaissables: rand(1..100),
      produits_subventions_etat: rand(1..100),
      produits_fiscalite_affectee: rand(1..100),
      produits_subventions_autres: rand(1..100),
      produits_autres: rand(1..100),
      produits_non_encaissables: rand(1..100),
      emplois_cout_total: rand(1..100),
      emplois_cout_investissements: rand(1..100),
      ressources_financement_etat: rand(1..100),
      ressources_autres: rand(1..100),
      decaissements_emprunts: rand(1..100),
      encaissements_emprunts: rand(1..100),
      decaissements_operations: rand(1..100),
      encaissements_operations: rand(1..100),
      decaissements_autres: rand(1..100),
      encaissements_autres: rand(1..100),
      ressources_total: rand(1..100)
    )
  end
end