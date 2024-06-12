ActiveAdmin.register Operateur do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :organisme_id, :operateur_n, :operateur_n1, :operateur_n2, :presence_categorie, :nom_categorie, :mission_id, :programme_id, :operateur_nf
  #
  # or
  #
  # permit_params do
  #   permitted = [:organisme_id, :operateur_n, :operateur_n1, :operateur_n2, :presence_categorie, :nom_categorie, :mission_id, :programme_id, :operateur_nf]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
