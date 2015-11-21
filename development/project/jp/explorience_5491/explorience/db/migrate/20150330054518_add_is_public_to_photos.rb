class AddIsPublicToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :published, :boolean, :default => true
  end
end
