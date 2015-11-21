class CreateGuides < ActiveRecord::Migration
  def change
    create_table :guides do |t|
      t.integer :section, null: false
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
