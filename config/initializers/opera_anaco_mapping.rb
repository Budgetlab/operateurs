# frozen_string_literal: true

# Mapping between OPERA controleur names and their ANACO equivalent.
# Used by the "Nature de contrôle" export (OrganismesController#export_nature_controle)
# to enrich the export with the ANACO name of each controleur.
OPERA_ANACO_MAPPING = {
  'CBCM Affaires étrangères' => 'DCB Affaires Etrangères',
  'CBCM Agriculture' => 'DCB Agriculture',
  'CBCM Armées' => 'DCB Armées',
  'CBCM Culture' => 'DCB Culture',
  'CBCM Ecologie/Développement durable/Transports et Logement' => 'DCB Ecologie',
  'CBCM Intérieur/ Outre-mer' => 'DCB Intérieur Outre-mer',
  'CBCM Justice' => 'DCB Justice-SPM',
  'CBCM MASS' => 'DCB Sociaux',
  'CBCM MEN-MESRI' => 'DCB Éducation - Ens.Sup.Recherche',
  'CBCM MINEFI' => 'DCB Économie Finances',
  'CBCM SPM' => 'DCB Justice-SPM',
  'DRFiP Auvergne-Rhône-Alpes' => 'CBR Auvergne Rhône Alpes',
  'DRFiP Bourgogne-Franche-Comté' => 'CBR Bourgogne Franche Comté',
  'DRFiP Bretagne' => 'CBR Bretagne',
  'DRFiP Centre Val de Loire' => 'CBR Centre Val de Loire',
  'DRFiP Corse' => 'CBR Corse',
  'DRFiP Grand-Est' => 'CBR Grand Est',
  'DRFiP Guadeloupe' => 'CBR Guadeloupe',
  'DRFiP Guyane' => 'CBR Guyane',
  'DRFiP Hauts-de-France' => 'CBR Hauts de France',
  'DRFiP IDF' => 'CBR Ile de France',
  'DRFiP Martinique' => 'CBR Martinique',
  'DRFiP Normandie' => 'CBR Normandie',
  'DRFiP Nouvelle Aquitaine' => 'CBR Nouvelle Aquitaine',
  'DRFiP Occitanie' => 'CBR Occitanie',
  'DRFiP PACA' => "CBR Provence Alpes Côte d'Azur",
  'DRFiP Pays de la Loire' => 'CBR Pays de Loire',
  'DRFiP Réunion' => 'CBR Réunion',
  'DFiP Nouvelle-Calédonie' => 'CBR Nouvelle Calédonie',
  'DFiP Wallis et Futuna' => 'CBR Wallis et Futuna',
  'DFiP Saint Pierre et Miquelon' => 'CBR St Pierre et Miquelon',
  'DFiP Polynésie-Française' => 'CBR Polynésie Française'
}.freeze
