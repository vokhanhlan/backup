class CreateClickings < ActiveRecord::Migration
  def change
    create_table :clickings do |t|
      t.references :experience, index: true
      t.references :user, index: true
      t.integer    :context, limit: 1, null: false
      t.boolean    :deleted, default: false
      t.timestamps
    end
  end
end
