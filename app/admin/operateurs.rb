ActiveAdmin.register Operateur do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :organisme_id, :presence_categorie, :nom_categorie, :mission_id, :programme_id, annees: []
  
end
