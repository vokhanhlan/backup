class CreateInvalidImages < ActiveRecord::Migration
  def change
    create_table :invalid_images do |t|
      t.integer :photo_id
      t.integer :uploader_id

      t.timestamps
    end
    add_index :invalid_images, :photo_id
    add_index :invalid_images, :uploader_id
  end
end
