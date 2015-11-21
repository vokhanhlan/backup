ActiveAdmin.register Photo do
  menu priority: 3

  # 表示項目
  index do
    selectable_column
    id_column
    column :experience do |photo|
      (photo.experiences.present?)? photo.experiences.first.id : "未登録"
    end
    column :image do |photo|
      image_tag photo.img.url(:normal)
    end
    column :img_file_name
    column :img_content_type
    column :img_file_size
    column :img_updated_at
    column :created_at
    column :updated_at
    actions
  end

  show do |photo|
    panel "#{photo.id}" do
      attributes_table_for photo do
        row :experience do
          (photo.experiences.present?)? photo.experiences.first.id : "未登録"
        end
        row :image do
          image_tag(photo.img.url(:normal))
        end
      end
      attributes_table_for photo, :img_file_name, :img_content_type, :img_file_size, :img_updated_at, :created_at, :updated_at
    end
  end

  # 入力項目
  form html: { enctype: "multipart/form-data" } do |f|
    f.inputs "Photos" do
      # single file upload
      f.input :img, as: :file, hint: f.object.new_record? ? "" : f.image_tag(f.object.img.url(:normal))
      # drag and drop area (for multiple file upload, only new page)
      if f.object.new_record?
        div id: "droppable", class: "droppable-box" do
          i class: "fa fa-image"
          span "ここにファイルをドラッグ&ドロップしてください（複数入力可）"
        end
      end
      span "Selected files", class: "images-description"
      div id: "loadedImages", class: "images-preview-box"
      div id: "hiddenInputs"
    end
    f.actions
  end

  controller do
    def create
      ActiveRecord::Base.transaction do
        raise "Select image file." unless params[:photo]
        # Create selected image
        Photo.create!(img: params[:photo][:img]) if params[:photo][:img]
        # Create dropped images
        if params[:photo][:dropped_photos]
          dropped_photos = []
          # FIXME: bulk insertするとinsertされるが画像ファイルが生成されない
          params[:photo][:dropped_photos].each do |_, hash|
            # NOTE: file名がUTF-8-MACで渡されるので、UTF-8に変換
            encoded_name = hash[:name].encode('UTF-8', 'UTF-8-MAC')
            Photo.create!(img: hash[:img], img_file_name: encoded_name)
            # dropped_photos << Photo.new(img: hash[:img], img_file_name: hash[:name])
          end
          # Photo.import dropped_photos unless dropped_photos.empty?
        end
        redirect_to admin_photos_path
      end
    rescue Exception => e
      flash[:error] = "Failed to create photo. #{e.message}"
      # NOTE: Photo.newせずにrenderするとRecordNotFoundが発生するため@photo生成
      @photo = Photo.new
      render action: "new"
    end

    def update
      ActiveRecord::Base.transaction do
        raise "Select image file." unless params[:photo]
        photo = Photo.find(params[:id])
        photo.update_attributes(img: params[:photo][:img])
        flash[:notice] = "Succeeded to update photo"
        redirect_to admin_photos_path
      end
    rescue Exception => e
      flash[:error] = "Failed to update photo. #{e.message}"
      render action: "edit"
    end
  end

  permit_params :img, :img_file_name, :img_content_type, :img_file_size
end
