ActiveAdmin.register Programme do
  permit_params :numero, :nom, :statut

  index do
    selectable_column
    id_column
    column :numero
    column :nom
    column :statut
    column :created_at
    column :updated_at
    actions
  end

  filter :numero
  filter :nom
  filter :statut, as: :select, collection: ['actif', 'inactif']
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :numero
      f.input :nom
      f.input :statut, as: :select, collection: ['actif', 'inactif'], include_blank: false
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :numero
      row :nom
      row :statut
      row :created_at
      row :updated_at
    end

    panel "Missions associées" do
      table_for programme.missions do
        column :nom
        column :statut
        column "Actions" do |mission|
          link_to "Voir", admin_mission_path(mission)
        end
      end
    end
  end
end
