class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.references :user, index: true
      t.integer :sns_type, limit: 1, null: false
      t.string  :sns_id, null: false
      t.string  :nickname, limit: 40
      t.string  :photo_url
      t.timestamps
    end
  end
end
