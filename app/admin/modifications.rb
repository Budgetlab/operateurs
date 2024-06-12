ActiveAdmin.register Modification do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :organisme_id, :user_id, :champ, :statut, :ancienne_valeur, :nouvelle_valeur, :commentaire, :nom
  #
  # or
  #
  # permit_params do
  #   permitted = [:organisme_id, :user_id, :champ, :statut, :ancienne_valeur, :nouvelle_valeur, :commentaire, :nom]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
