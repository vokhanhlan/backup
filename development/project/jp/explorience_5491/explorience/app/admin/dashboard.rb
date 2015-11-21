ActiveAdmin.register_page "Dashboard" do
  #管理画面タイトル設定
  menu priority: 1, label: proc{ "Dashboard" }

  content title: proc{ "Dashboard" } do
    #直近で追加されたInvalidImage
    section "Recently added unauthorized using image reports" do
      table_for InvalidImage.order(created_at: :desc).limit(5) do
        column :id
        column :photo_id
        column :uploader_id
        column :created_at
        column :updated_at
      end
    end

    #直近で追加されたExperience
    section "Recently added Experiences" do
      table_for Experience.posted_order.limit(5) do
        column :id
        column :advertiser
        column :title
        column :address
        column :workday
        column :start_date
        column :end_date
        column :tel
        column :price
        column :created_at
        column :updated_at
      end
    end

    #直近で追加されたUser
    section "Recently added Users" do
      table_for User.order(created_at: :desc).limit(5) do
        column :id
        column :name
        column :email
        column :sign_in_count
        column :last_sign_in_at
        column :last_sign_in_ip
        column :created_at
        column :updated_at
      end
    end
  end
end
