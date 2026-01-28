ActiveAdmin.register Mission do
  permit_params :nom, :programme_id, :statut

  index do
    selectable_column
    id_column
    column :nom
    column :programme do |mission|
      link_to "#{mission.programme.numero} - #{mission.programme.nom}", admin_programme_path(mission.programme) if mission.programme
    end
    column :statut
    column :created_at
    column :updated_at
    actions
  end

  filter :nom
  filter :programme, as: :select, collection: -> { Programme.order(:numero).map { |p| ["#{p.numero} - #{p.nom}", p.id] } }
  filter :statut, as: :select, collection: ['actif', 'inactif']
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :nom
      f.input :programme, as: :select, collection: Programme.order(:numero).map { |p| ["#{p.numero} - #{p.nom}", p.id] }, include_blank: false
      f.input :statut, as: :select, collection: ['actif', 'inactif'], include_blank: false
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :nom
      row :programme do |mission|
        link_to "#{mission.programme.numero} - #{mission.programme.nom}", admin_programme_path(mission.programme) if mission.programme
      end
      row :statut
      row :created_at
      row :updated_at
    end
  end
end
