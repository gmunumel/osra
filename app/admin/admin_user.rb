ActiveAdmin.register AdminUser do

  config.filters = false

  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email, sortable: :email do |user|
      link_to user.email, admin_admin_user_path(user)
    end
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
