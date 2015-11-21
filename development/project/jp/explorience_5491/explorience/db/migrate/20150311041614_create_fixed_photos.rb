class CreateFixedPhotos < ActiveRecord::Migration
  def change
    create_table :fixed_photos do |t|
      t.references :user, index: true
      t.integer :experience_id
      t.integer :photo_id

      t.timestamps
    end
  end
end
