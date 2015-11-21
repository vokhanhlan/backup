ActiveAdmin.register AdminUser do
  menu priority: 17, label: proc{ "Administrators" }

  #表示項目
  index do
    selectable_column
    id_column
    column :email
    column :sign_in_count
    column :last_sign_in_at
    column :created_at
    actions
  end

  #検索項目
  filter :email
  filter :sign_in_count
  filter :last_sign_in_at
  filter :created_at

  #入力項目
  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  permit_params :email, :password, :password_confirmation

end
