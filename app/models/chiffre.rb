# frozen_string_literal: true

# Model Chiffre
class Chiffre < ApplicationRecord
  include ApplicationHelper
  belongs_to :organisme
  belongs_to :user

  # Part des personnels exerçant leurs missions dans l'organisme dans le total des emplois rémunérés directement par l'organisme
  def indicateur_part_personnel_organisme
    numerateur = emplois_total + (emplois_non_remuneres || 0) - (emplois_autre_entite || 0)
    ratio(numerateur, emplois_total, 100)
  end

  def indicateur_poids_depenses_personnel
    denominateur = (credits_cp_total || 0) - (credits_cp_investissement || 0)
    ratio(emplois_depenses_personnel, denominateur, 100)
  end

  def subv_etat
    (credits_financements_etat_autres || 0) + (credits_financements_etat_fleches || 0) + (credits_subvention_sp || 0) + (credits_subvention_investissement_globalisee || 0) + (credits_subvention_investissement_flechee || 0)
  end

  def recettes_globalisees
    (credits_financements_etat_autres || 0) + (credits_fiscalite_affectee || 0) + (credits_financements_publics_autres || 0) + (credits_recettes_propres_globalisees || 0) + (credits_subvention_sp || 0) + (credits_subvention_investissement_globalisee || 0)
  end
  def recettes_flechees
    (credits_financements_etat_fleches || 0) + (credits_financements_publics_fleches || 0) + (credits_recettes_propres_flechees || 0) + (credits_subvention_investissement_flechee || 0)
  end

  def recettes_total
    (credits_financements_etat_autres || 0) + (credits_fiscalite_affectee || 0) + (credits_financements_publics_autres || 0) + (credits_recettes_propres_globalisees || 0) + (credits_subvention_sp || 0) + (credits_subvention_investissement_globalisee || 0) + (credits_financements_etat_fleches || 0) + (credits_financements_publics_fleches || 0) + (credits_recettes_propres_flechees || 0) + (credits_subvention_investissement_flechee || 0)
  end

  def taux_couverture_scsp
    denominateur = (emplois_depenses_personnel || 0) + (credits_cp_fonctionnement || 0)
    ratio(credits_subvention_sp, denominateur, 100)
  end

  def poids_scsp
    total_recettes = (credits_financements_etat_autres || 0) + (credits_fiscalite_affectee || 0) + (credits_financements_publics_autres || 0) + (credits_recettes_propres_globalisees || 0) + (credits_subvention_sp || 0) + (credits_subvention_investissement_globalisee || 0) + (credits_financements_etat_fleches || 0) + (credits_financements_publics_fleches || 0) + (credits_recettes_propres_flechees || 0) + (credits_subvention_investissement_flechee || 0)
    ratio(credits_subvention_sp, total_recettes, 100)
  end

  def total_recettes_propres
    (credits_recettes_propres_globalisees || 0) + (credits_recettes_propres_flechees || 0)
  end

  def taux_recettes_propres
    numerateur = (credits_recettes_propres_globalisees || 0) + (credits_recettes_propres_flechees || 0)
    total_recettes = (credits_financements_etat_autres || 0) + (credits_fiscalite_affectee || 0) + (credits_financements_publics_autres || 0) + (credits_recettes_propres_globalisees || 0) + (credits_subvention_sp || 0) + (credits_subvention_investissement_globalisee || 0) + (credits_financements_etat_fleches || 0) + (credits_financements_publics_fleches || 0) + (credits_recettes_propres_flechees || 0) + (credits_subvention_investissement_flechee || 0)
    ratio(numerateur,total_recettes,100)
  end
  def solde_budgetaire
    (credits_financements_etat_autres || 0) + (credits_fiscalite_affectee || 0) + (credits_financements_publics_autres || 0) + (credits_recettes_propres_globalisees || 0) + (credits_subvention_sp || 0) + (credits_subvention_investissement_globalisee || 0) + (credits_financements_etat_fleches || 0) + (credits_financements_publics_fleches || 0) + (credits_recettes_propres_flechees || 0) + (credits_subvention_investissement_flechee || 0) - (credits_cp_total || 0)
  end

  def solde_budgetaire_fleche
    (credits_financements_etat_fleches || 0) + (credits_financements_publics_fleches || 0) + (credits_recettes_propres_flechees || 0) + (credits_subvention_investissement_flechee || 0) - (credits_cp_recettes_flechees || 0)
  end

  def var_restes_a_payer
    (credits_ae_total || 0) - (credits_cp_total || 0)
  end

  def poids_restes_a_payer
    denominateur = (credits_cp_total || 0) - (emplois_depenses_personnel || 0)
    ratio(credits_restes_a_payer,denominateur,100)
  end

  def total_charges
    (emplois_charges_personnel || 0) + (charges_fonctionnement || 0) + (charges_intervention || 0)
  end

  def total_produits
    (produits_subventions_etat || 0) + (produits_fiscalite_affectee || 0) + (produits_subventions_autres || 0) + (produits_autres || 0)
  end

  def charges_decaissables
    (emplois_charges_personnel || 0) + (charges_fonctionnement || 0) + (charges_intervention || 0) - (charges_non_decaissables || 0)
  end

  def encaissements_non_budgetaires
    (encaissements_operations || 0) + (encaissements_emprunts || 0) + (encaissements_autres || 0)
  end

  def decaissements_non_budgetaires
    (decaissements_operations || 0) + (decaissements_emprunts || 0) + (decaissements_autres || 0)
  end

  def jours_fonctionnement_tresorerie
    charges_decaissables = (emplois_charges_personnel || 0) + (charges_fonctionnement || 0) + (charges_intervention || 0) - (charges_non_decaissables || 0)
    denominateur = comptabilite_budgetaire ? ((credits_cp_total || 0) - (credits_cp_investissement || 0)) / 360 : charges_decaissables / 360
    ratio(tresorerie_finale,denominateur,1)
  end

  def jours_fonctionnement_tresorerie_non_flechee
    charges_decaissables = (emplois_charges_personnel || 0) + (charges_fonctionnement || 0) + (charges_intervention || 0) - (charges_non_decaissables || 0)
    denominateur = comptabilite_budgetaire ? ((credits_cp_total || 0) - (credits_cp_investissement || 0)) / 360 : charges_decaissables / 360
    ratio(tresorerie_finale_non_flechee,denominateur,1)
  end

  def jours_fonctionnement_tresorerie_min
    charges_decaissables = (emplois_charges_personnel || 0) + (charges_fonctionnement || 0) + (charges_intervention || 0) - (charges_non_decaissables || 0)
    denominateur = comptabilite_budgetaire ? ((credits_cp_total || 0) - (credits_cp_investissement || 0)) / 360 : charges_decaissables / 360
    ratio(tresorerie_min,denominateur,1)
  end

  def jours_fonctionnement_tresorerie_max
    charges_decaissables = (emplois_charges_personnel || 0) + (charges_fonctionnement || 0) + (charges_intervention || 0) - (charges_non_decaissables || 0)
    denominateur = comptabilite_budgetaire ? ((credits_cp_total || 0) - (credits_cp_investissement || 0)) / 360 : charges_decaissables / 360
    ratio(tresorerie_max,denominateur,1)
  end

  def variation_bfr
    (fonds_roulement_variation || 0) - (tresorerie_variation || 0)
  end

  def self.ransackable_attributes(auth_object = nil)
    ["capacite_autofinancement", "charges_fonctionnement", "charges_intervention", "charges_non_decaissables", "commentaire", "commentaire_annexe", "comptabilite_budgetaire", "created_at", "credits_ae_fonctionnement", "credits_ae_intervention", "credits_ae_investissement", "credits_ae_total", "credits_cp_fonctionnement", "credits_cp_intervention", "credits_cp_investissement", "credits_cp_operations", "credits_cp_recettes_flechees", "credits_cp_total", "credits_financements_etat_autres", "credits_financements_etat_fleches", "credits_financements_publics_autres", "credits_financements_publics_fleches", "credits_fiscalite_affectee", "credits_recettes_propres_flechees", "credits_recettes_propres_globalisees", "credits_restes_a_payer", "credits_subvention_investissement_flechee", "credits_subvention_investissement_globalisee", "credits_subvention_sp", "decaissements_autres", "decaissements_emprunts", "decaissements_operations", "emplois_autre_entite", "emplois_charges_personnel", "emplois_contractuels", "emplois_contractuels_montant", "emplois_cout_investissements", "emplois_cout_total", "emplois_depenses_personnel", "emplois_hors_plafond", "emplois_non_remuneres", "emplois_plafond", "emplois_plafond_prenotifie", "emplois_plafond_rappel", "emplois_schema", "emplois_schema_prenotifie", "emplois_titulaires", "emplois_titulaires_montant", "emplois_total", "encaissements_autres", "encaissements_emprunts", "encaissements_operations", "exercice_budgetaire", "fonds_roulement_besoin_final", "fonds_roulement_final", "fonds_roulement_variation", "id", "id_value", "operateur", "organisme_id", "phase", "produits_autres", "produits_fiscalite_affectee", "produits_non_encaissables", "produits_subventions_autres", "produits_subventions_etat", "ressources_autres", "ressources_financement_etat", "ressources_total", "risque_insolvabilite", "statut", "tresorerie_finale", "tresorerie_finale_flechee", "tresorerie_finale_non_flechee", "tresorerie_max", "tresorerie_max_date", "tresorerie_min", "tresorerie_min_date", "tresorerie_variation", "tresorerie_variation_flechee", "tresorerie_variation_non_flechee", "type_budget", "updated_at", "user_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["organisme", "user"]
  end

end
