class CreateAdvertisers < ActiveRecord::Migration
  def change
    create_table :advertisers do |t|
      t.string  :name,    null: false
      t.integer :ad_type, null: false, limit: 1
      t.timestamps
    end
  end
end
