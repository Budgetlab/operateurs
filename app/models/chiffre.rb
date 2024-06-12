# frozen_string_literal: true

# Model Chiffre
class Chiffre < ApplicationRecord
  include ApplicationHelper
  belongs_to :organisme
  belongs_to :user

  # Part des personnels exerçant leurs missions dans l'organisme dans le total des emplois rémunérés directement par l'organisme
  def indicateur_part_personnel_organisme
    numerateur = emplois_autre_entite ? emplois_total + (emplois_non_remuneres || 0) - (emplois_autre_entite || 0) : nil
    ratio(numerateur, emplois_total, 100)
  end

  # Hors-plafond / total effectifs rémunérés par l'organisme
  def ratio_hors_plafond
    ratio(emplois_hors_plafond, emplois_total, 100)
  end

  # Coût moyen par ETPT
  def cout_moyen_etpt
    numerateur = comptabilite_budgetaire ? emplois_depenses_personnel : emplois_charges_personnel
    ratio(numerateur, emplois_total, 1)
  end

  # Coût moyen des emplois titulaires
  def cout_moyen_titulaires
    ratio(emplois_titulaires_montant, emplois_titulaires, 1)
  end

  # Coût moyen des emplois contractuels
  def cout_moyen_contractuels
    ratio(emplois_contractuels_montant, emplois_contractuels, 1)
  end

  # Part des contractuels dans le total des emplois rémunérés par l’organisme
  def part_contractuels
    ratio(emplois_contractuels, emplois_total, 100)
  end

  # Poids des dépenses de personnel
  def indicateur_poids_depenses_personnel
    denominateur = (credits_cp_total || 0) - (credits_cp_investissement || 0)
    ratio(emplois_depenses_personnel, denominateur, 100)
  end

  # Part relative des dépenses de fonctionnement (CP) dans le total des dépenses (CP)
  def part_cp_fonctionnement
    ratio(credits_cp_fonctionnement, credits_cp_total, 100)
  end

  # Part relative des dépenses d'intervention (CP) dans le total des dépenses (CP)
  def part_cp_intervention
    ratio(credits_cp_intervention, credits_cp_total, 100)
  end

  # Part relative des dépenses d'investissement (CP) dans le total des dépenses (CP)
  def part_cp_investissement
    ratio(credits_cp_investissement, credits_cp_total, 100)
  end

  # Poids des crédits de paiement au titre d'opérations pluriannuelles
  def poids_cp_operations
    ratio(credits_cp_operations, credits_cp_total, 100)
  end

  # Total des subventions de l’Etat
  def subv_etat
    (credits_financements_etat_autres || 0) + (credits_financements_etat_fleches || 0) + (credits_subvention_sp || 0) + (credits_subvention_investissement_globalisee || 0) + (credits_subvention_investissement_flechee || 0)
  end

  # Total des recettes globalisées
  def recettes_globalisees
    (credits_financements_etat_autres || 0) + (credits_fiscalite_affectee || 0) + (credits_financements_publics_autres || 0) + (credits_recettes_propres_globalisees || 0) + (credits_subvention_sp || 0) + (credits_subvention_investissement_globalisee || 0)
  end

  # Total des recettes fléchées
  def recettes_flechees
    (credits_financements_etat_fleches || 0) + (credits_financements_publics_fleches || 0) + (credits_recettes_propres_flechees || 0) + (credits_subvention_investissement_flechee || 0)
  end

  # Total des recettes
  def recettes_total
    recettes_globalisees + recettes_flechees
  end

  # Poids des recettes non fléchées
  def poids_recettes_globalisees
    ratio(recettes_globalisees,recettes_total,100)
  end

  # Poids des financements de l’Etat suvb etat / total recettes
  def poids_financements_etat
    ratio(subv_etat, recettes_total, 100)
  end

  # Taux de couverture des dépenses de personnel et de fonctionnement par de la SCSP
  def taux_couverture_scsp
    denominateur = (emplois_depenses_personnel || 0) + (credits_cp_fonctionnement || 0)
    ratio(credits_subvention_sp, denominateur, 100)
  end

  # Poids de la SCSP sur recettes totales
  def poids_scsp
    ratio(credits_subvention_sp, recettes_total, 100)
  end

  # Total des recettes propres
  def total_recettes_propres
    (credits_recettes_propres_globalisees || 0) + (credits_recettes_propres_flechees || 0)
  end

  # Taux de recettes propres
  def taux_recettes_propres
    ratio(total_recettes_propres,recettes_total,100)
  end

  # Solde budgétaire = total_recettes - credits_cp_total
  def solde_budgetaire
    recettes_total - (credits_cp_total || 0)
  end

  # Solde budgétaire résultant des opérations fléchées = total_recettes_flechees-credits_cp_recettes_flechees
  def solde_budgetaire_fleche
    credits_cp_recettes_flechees ? recettes_flechees - (credits_cp_recettes_flechees || 0) : nil
  end

  # Variations des restes à payer
  def var_restes_a_payer
    (credits_ae_total || 0) - (credits_cp_total || 0)
  end

  # Poids des restes à payer
  def poids_restes_a_payer
    denominateur = (credits_cp_total || 0) - (emplois_depenses_personnel || 0)
    ratio(credits_restes_a_payer,denominateur,100)
  end

  # Total des charges
  def total_charges
    (emplois_charges_personnel || 0) + (charges_fonctionnement || 0) + (charges_intervention || 0)
  end

  # Total des produits
  def total_produits
    (produits_subventions_etat || 0) + (produits_fiscalite_affectee || 0) + (produits_subventions_autres || 0) + (produits_autres || 0)
  end

  # résultat
  def resultat
    total_produits - total_charges
  end

  def charges_decaissables
    total_charges - (charges_non_decaissables || 0)
  end

  # Poids relatif des charges de personnel
  def poids_charges_personnel
    ratio(emplois_charges_personnel, charges_decaissables, 100)
  end

  # Poids des charges de fonctionnement
  def poids_charges_fonctionnement
    ratio(charges_fonctionnement, charges_decaissables, 100)
  end

  # Poids des charges d'intervention
  def poids_charges_intervention
    ratio(charges_intervention, charges_decaissables, 100)
  end

  # Taux de ressources propres
  def taux_ressources_propres
    numerateur = produits_autres - (produits_non_encaissables || 0) + ressources_autres
    denominateur = total_produits - (produits_non_encaissables || 0) + ressources_total - capacite_autofinancement
    ratio(numerateur, denominateur, 100)
  end

  def encaissements_non_budgetaires
    encaissements_operations.nil? && encaissements_emprunts.nil? && encaissements_autres.nil? ? nil : (encaissements_operations || 0) + (encaissements_emprunts || 0) + (encaissements_autres || 0)
  end

  def decaissements_non_budgetaires
    decaissements_operations.nil? && decaissements_emprunts.nil? && decaissements_autres.nil? ? nil : (decaissements_operations || 0) + (decaissements_emprunts || 0) + (decaissements_autres || 0)
  end

  def jours_fonctionnement_tresorerie
    denominateur = comptabilite_budgetaire ? ((credits_cp_total || 0) - (credits_cp_investissement || 0)) / 360 : charges_decaissables / 360
    ratio(tresorerie_finale,denominateur,1)
  end

  # Taux de couverture des restes à payer par la trésorerie
  def taux_couverture_rap
    ratio(tresorerie_finale, credits_restes_a_payer, 100)
  end

  # Niveau initial de trésorerie
  def tresorerie_initiale
    (tresorerie_finale || 0) - (tresorerie_variation || 0)
  end

  def jours_fonctionnement_tresorerie_non_flechee
    denominateur = comptabilite_budgetaire ? ((credits_cp_total || 0) - (credits_cp_investissement || 0)) / 360 : charges_decaissables / 360
    ratio(tresorerie_finale_non_flechee,denominateur,1)
  end

  # Poids de la trésorerie non fléchée
  def poids_tresorerie_non_flechee
    ratio(tresorerie_finale_non_flechee, tresorerie_finale, 100)
  end

  def jours_fonctionnement_tresorerie_min
    denominateur = comptabilite_budgetaire ? ((credits_cp_total || 0) - (credits_cp_investissement || 0)) / 360 : charges_decaissables / 360
    ratio(tresorerie_min,denominateur,1)
  end

  def jours_fonctionnement_tresorerie_max
    denominateur = comptabilite_budgetaire ? ((credits_cp_total || 0) - (credits_cp_investissement || 0)) / 360 : charges_decaissables / 360
    ratio(tresorerie_max,denominateur,1)
  end

  def variation_bfr
    (fonds_roulement_variation || 0) - (tresorerie_variation || 0)
  end

  # Niveau initial du besoin en fonds de roulement
  def fonds_roulement_besoin_initial
    fonds_roulement_besoin_final ? fonds_roulement_besoin_final - variation_bfr : nil
  end

  # Niveau initial du fonds de roulement
  def fonds_roulement_initial
    (fonds_roulement_final || 0) - (fonds_roulement_variation || 0)
  end

  def self.ransackable_attributes(auth_object = nil)
    ["capacite_autofinancement", "charges_fonctionnement", "charges_intervention", "charges_non_decaissables", "commentaire", "commentaire_annexe", "comptabilite_budgetaire", "created_at", "credits_ae_fonctionnement", "credits_ae_intervention", "credits_ae_investissement", "credits_ae_total", "credits_cp_fonctionnement", "credits_cp_intervention", "credits_cp_investissement", "credits_cp_operations", "credits_cp_recettes_flechees", "credits_cp_total", "credits_financements_etat_autres", "credits_financements_etat_fleches", "credits_financements_publics_autres", "credits_financements_publics_fleches", "credits_fiscalite_affectee", "credits_recettes_propres_flechees", "credits_recettes_propres_globalisees", "credits_restes_a_payer", "credits_subvention_investissement_flechee", "credits_subvention_investissement_globalisee", "credits_subvention_sp", "decaissements_autres", "decaissements_emprunts", "decaissements_operations", "emplois_autre_entite", "emplois_charges_personnel", "emplois_contractuels", "emplois_contractuels_montant", "emplois_cout_investissements", "emplois_cout_total", "emplois_depenses_personnel", "emplois_hors_plafond", "emplois_non_remuneres", "emplois_plafond", "emplois_plafond_prenotifie", "emplois_plafond_rappel", "emplois_schema", "emplois_schema_prenotifie", "emplois_titulaires", "emplois_titulaires_montant", "emplois_total", "encaissements_autres", "encaissements_emprunts", "encaissements_operations", "exercice_budgetaire", "fonds_roulement_besoin_final", "fonds_roulement_final", "fonds_roulement_variation", "id", "id_value", "operateur", "organisme_id", "phase", "produits_autres", "produits_fiscalite_affectee", "produits_non_encaissables", "produits_subventions_autres", "produits_subventions_etat", "ressources_autres", "ressources_financement_etat", "ressources_total", "risque_insolvabilite", "statut", "tresorerie_finale", "tresorerie_finale_flechee", "tresorerie_finale_non_flechee", "tresorerie_max", "tresorerie_max_date", "tresorerie_min", "tresorerie_min_date", "tresorerie_variation", "tresorerie_variation_flechee", "tresorerie_variation_non_flechee", "type_budget", "updated_at", "user_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["organisme", "user"]
  end

end
