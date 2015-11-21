class CreateReporters < ActiveRecord::Migration
  def change
    create_table :reporters do |t|
      t.integer :invalid_image_id
      t.integer :user_id
      t.integer :invalid_type, limit: 1, null: false
      t.text :reason
      t.references :invalid_image, index: true

      t.timestamps
    end
    add_index :reporters, :user_id
  end
end
