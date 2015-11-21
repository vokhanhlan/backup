class CreatePostToCategories < ActiveRecord::Migration
  def change
    create_table :post_to_categories do |t|
      t.integer :category_id, limit: 4, null: false
      t.integer :post_id,     limit: 4, null: false

      t.timestamps null: false
    end
  end
end
