ActiveAdmin.register Guide do
  menu priority: 15

  index title: "Guides" do
    selectable_column
    id_column
    column :title
    column :body
    actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs do
      f.input :section
      f.input :title_ja
      f.input :title_en
      f.input :body_ja, as: :text
      f.input :body_en, as: :text
    end
    f.actions
  end

  show do |guide|
    panel "ID: #{guide.id}" do
      attributes_table_for guide, :section, :title_ja, :title_en, :body_ja, :body_en
    end
  end

  permit_params :section, :title_ja, :title_en, :body_ja, :body_en
end
