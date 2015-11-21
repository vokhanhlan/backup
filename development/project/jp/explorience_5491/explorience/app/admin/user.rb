ActiveAdmin.register User do
  #管理画面タイトル設定
  menu priority: 16, label: proc{ "Users" }

  #表示項目
  index do
    selectable_column
    id_column
    column :name
    column :email
    column :sign_in_count
    column :last_sign_in_at
    column :created_at
    column :sns_type do |product|
      if product.providers.present?
        status_tag(product.providers.first.sns_type)
      end
    end
    actions
  end

  #検索項目
  filter :name
  filter :email
  filter :sign_in_count
  filter :last_sign_in_at
  filter :created_at

end
