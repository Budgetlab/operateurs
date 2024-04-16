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

end
