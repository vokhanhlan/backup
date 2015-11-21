ActiveAdmin.register InvalidImage do
  menu priority: 90, label: "Unauthorized using image reports"

  # defaultのaction items非表示
  config.clear_action_items!

  # 表示項目
  index title: "不正使用の疑いがある投稿画像の通報一覧" do
    selectable_column
    id_column
    column :photo_id
    column :image do |invalid_image|
      image_tag Photo.find(invalid_image.photo_id).img.url(:normal)
    end
    column :uploader_id
    column :uploader_name do |invalid_image|
      User.find(invalid_image.uploader_id).name
    end
    column :first_reporter_name do |invalid_image|
      invalid_image.reporters.first.user_id ? User.find(invalid_image.reporters.first.user_id).name : "未登録者"
    end
    column :first_report_invalid_reason do |invalid_image|
      invalid_image.reporters.first.invalid_type
    end
    column :created_at
    #column :updated_at
    column :accept do |invalid_image|
      # FIXME: button_toで表示するとクリック時にCouldn't find batch action "" のエラーが出てしまう
      link_to '受理',
        accept_admin_invalid_image_path(id: invalid_image.id, photo_id: invalid_image.photo_id),
        class: "btn btn--action", method: :post, data: { confirm: 'この通報を受理して対象画像を削除しますか？' }
    end
    column :reject do |invalid_image|
      # FIXME: button_toで表示するとクリック時にCouldn't find batch action "" のエラーが出てしまう
      link_to '拒否', admin_invalid_image_path(invalid_image.id),
        class: "btn btn--action", method: :delete, data: { confirm: 'この通報を拒否しますか？' }
    end
  end

  show title: "通報詳細" do |invalid_image|
    panel "ID: #{invalid_image.id}" do
      photo = Photo.find(invalid_image.photo_id)
      user  = User.find(invalid_image.uploader_id)
      attributes_table_for invalid_image, :photo_id
      attributes_table_for invalid_image do
        row :image do
          image_tag photo.img.url(:normal)
        end
      end
      attributes_table_for invalid_image, :uploader_id
      attributes_table_for invalid_image do
        row :uploader_name do
          user.name
        end
        row :uploaded_at do
          photo.created_at
        end
      end
      attributes_table_for invalid_image, :created_at, :updated_at
    end
    invalid_image.reporters.each do |reporter|
      reporter_name = reporter.user_id ? User.find(reporter.user_id).name : "未登録者"
      panel "Reported from #{reporter_name} (ID: #{(reporter.user_id)? reporter.user_id : "none"})" do
        attributes_table_for reporter do
          row :email
          row :invalid_type
          row :reason
        end
      end
    end
  end

  # show画面でのaction itemの追加
  action_item :accept_report, only: :show do
    photo_id = InvalidImage.find(params[:id]).photo_id
    link_to 'この通報を受理する',
      accept_admin_invalid_image_path(id: params[:id], photo_id: photo_id),
      method: :post, data: { confirm: 'この通報を受理して対象画像を削除しますか？' }
  end

  action_item :reject_report, only: :show do
    link_to 'この通報を拒否する', admin_invalid_image_path(invalid_image.id),
      method: :delete, data: { confirm: 'この通報を拒否しますか？' }
  end

  # 報告画像の削除アクション
  member_action :accept, method: :post do
    begin
      ActiveRecord::Base.transaction do
        Photo.find(params[:photo_id]).destroy
        InvalidImage.find(params[:id]).destroy
        redirect_to url_for(action: :index), notice: "通報ID#{params[:id]}を受理し画像ID#{params[:photo_id]}を削除しました"
      end
    rescue => e
      redirect_to url_for(action: :index), flash: { error: "通報ID#{params[:id]}で報告された不正画像ファイルの削除に失敗しました。#{e.message}" }
    end
  end

  # destroyアクションの出力メッセージ変更
  controller do
    def destroy
      InvalidImage.find(params[:id]).destroy
      redirect_to url_for(action: :index), notice: "通報ID#{params[:id]}を拒否しました"
    rescue => e
      redirect_to url_for(action: :index), flash: { error: "通報ID#{params[:id]}の拒否に失敗しました。#{e.message}" }
    end
  end
end
