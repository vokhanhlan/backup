class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :content,    null: false
      t.integer :user_id, null: false
      t.integer :post_id, null: false
      t.integer :parent_id, default: 0
      t.boolean :status,  default: 1

      t.timestamps null: false
    end
  end
end
