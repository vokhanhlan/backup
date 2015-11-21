class CreateExperiencePhotos < ActiveRecord::Migration
  def change
    create_table :experience_photos do |t|
      t.references :photo, index: true
      t.references :experience, index: true
      t.timestamps
    end
  end
end
