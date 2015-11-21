class TranslateTags < ActiveRecord::Migration
  def self.up
    ActsAsTaggableOn::Tag.create_translation_table!({
      name: { type: :string, unique: :true }
    }, {
      migrate_data: true,
    })
    add_index :tag_translations, [:name], unique: true
  end

  def self.down
    ActsAsTaggableOn::Tag.drop_translation_table! migrate_data: true
  end
end
