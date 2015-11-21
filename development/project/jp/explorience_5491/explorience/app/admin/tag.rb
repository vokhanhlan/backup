ActiveAdmin.register ActsAsTaggableOn::Tag, as: "Tags" do
  menu priority: 4

  index title: "Tags" do
    selectable_column
    id_column
    column :name_ja
    (I18n.available_locales - [:ja]).each { |locale| column :"name_#{locale}" }
    column :taggings_count
    actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs do
      f.input :name_ja
      (I18n.available_locales - [:ja]).each { |locale| f.input :"name_#{locale}" }
    end
    f.actions
  end

  controller do
    def create
      # ActsAsTaggableOnの各メソッドを使うため,
      # ActsAsTaggableOn::Tag.nameに:jaのparamとして保存する必要がある
      Globalize.with_locale(:ja) do
        names = {}
        I18n.available_locales.each do |locale|
          names["name_#{locale}".to_sym] = params[:acts_as_taggable_on_tag][:"name_#{locale}"]
        end
        ActsAsTaggableOn::Tag.create!(names)
      end
      flash[:notice] = "Succeeded to create tag."
      redirect_to admin_tags_path
    rescue
      flash[:error] = "Failed to create tag."
      redirect_to admin_tags_path
    end

    def update
      @tag = ActsAsTaggableOn::Tag.find_by(id: params[:id])
      Globalize.with_locale(:ja) do
        names = {}
        I18n.available_locales.each do |locale|
          names["name_#{locale}".to_sym] = params[:acts_as_taggable_on_tag][:"name_#{locale}"]
        end
        @tag.update_attributes(names)
      end
      flash[:notice] = "Succeeded to update tag."
      redirect_to admin_tags_path
    rescue
      flash[:error] = "Failed to update tag."
      redirect_to admin_tags_path
    end
  end

  show do |tag|
    panel "#{tag.id}" do
      attributes_table_for tag, :name_ja
      (I18n.available_locales - [:ja]).each { |locale| attributes_table_for tag, :"name_#{locale}" }
      attributes_table_for tag, :taggings_count
    end
    if tag.taggings_count > 0
      panel "タグ付与された体験" do
        exp_ids = ActsAsTaggableOn::Tagging.where(tag_id: tag.id).pluck(:taggable_id)
        exps = Experience.find(exp_ids)
        table do
          tr do
            th "ID"
            th "Image"
            th "Title"
            th "Description"
            th "Address"
          end
          exps.each do |exp|
            tr do
              td link_to exp.id, admin_experience_path(exp.id)
              td image_tag(exp.photos.first.img.url(:normal)) unless exp.photos.empty?
              td link_to exp.title, admin_experience_path(exp.id)
              td exp.description
              td exp.address
            end
          end
        end
      end
    end
  end

  # TODO HACK: 未使用であれば適切にstrong parameter使用するか削除する
  permit_params :name_ja, :name_en, :name_ko, :name_th, :taggings_count
end
