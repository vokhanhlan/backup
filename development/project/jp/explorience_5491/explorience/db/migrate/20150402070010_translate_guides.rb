class TranslateGuides < ActiveRecord::Migration
  def self.up
    Guide.create_translation_table!({
      title:    :string,
      body:     :text
    }, {
      migrate_data: true,
      remove_source_columns: true
    })
  end

  def self.down
    add_column :guides, :title, :string, after: :updated_at unless column_exists? :guides, :title
    add_column :guides, :body, :text, after: :updated_at unless column_exists? :guides, :body
    Guide.drop_translation_table! migrate_data: true
  end
end