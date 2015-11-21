class TranslateExperiences < ActiveRecord::Migration
  def self.up
    Experience.create_translation_table!({
      title:       { type: :string, null: false },
      description: { type: :text,   null: false },
      address: :string,
      workday: :string
    }, {
      migrate_data: true,
      remove_source_columns: true
    })
  end

  def self.down
    add_column :experiences, :title,       :string, { null: false, after: :id }    unless column_exists? :experiences, :title
    add_column :experiences, :description, :text,   { null: false, after: :title } unless column_exists? :experiences, :description
    add_column :experiences, :address,     :string, after: :description            unless column_exists? :experiences, :address
    add_column :experiences, :workday,     :string, after: :url                    unless column_exists? :experiences, :workday
    Experience.drop_translation_table! migrate_data: true
  end
end
