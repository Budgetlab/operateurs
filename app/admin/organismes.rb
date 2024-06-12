ActiveAdmin.register Organisme do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :etat, :siren, :acronyme, :nom, :famille, :nature, :date_creation, :date_dissolution, :date_previsionnelle_dissolution, :effet_dissolution, :bureau_id, :texte_institutif, :commentaire, :statut, :gbcp_1, :agent_comptable_present, :degre_gbcp, :gbcp_3, :comptabilite_budgetaire, :presence_controle, :nature_controle, :texte_soumission_controle, :autorite_controle, :controleur_id, :texte_reglementaire_controle, :arrete_controle, :document_controle_present, :document_controle_lien, :document_controle_date, :arrete_nomination, :tutelle_financiere, :delegation_approbation, :autorite_approbation, :admin_db_present, :admin_db_fonction, :admin_preca, :controleur_preca, :controleur_ca, :comite_audit, :apu, :ciassp_n, :ciassp_n1, :odac_n, :odac_n1, :odal_n, :odal_n1, :ministere_id, :arrete_interdiction_odac
  #
  # or
  #
  # permit_params do
  #   permitted = [:etat, :siren, :acronyme, :nom, :famille, :nature, :date_creation, :date_dissolution, :date_previsionnelle_dissolution, :effet_dissolution, :bureau_id, :texte_institutif, :commentaire, :statut, :gbcp_1, :agent_comptable_present, :degre_gbcp, :gbcp_3, :comptabilite_budgetaire, :presence_controle, :nature_controle, :texte_soumission_controle, :autorite_controle, :controleur_id, :texte_reglementaire_controle, :arrete_controle, :document_controle_present, :document_controle_lien, :document_controle_date, :arrete_nomination, :tutelle_financiere, :delegation_approbation, :autorite_approbation, :admin_db_present, :admin_db_fonction, :admin_preca, :controleur_preca, :controleur_ca, :comite_audit, :apu, :ciassp_n, :ciassp_n1, :odac_n, :odac_n1, :odal_n, :odal_n1, :ministere_id, :arrete_interdiction_odac]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
