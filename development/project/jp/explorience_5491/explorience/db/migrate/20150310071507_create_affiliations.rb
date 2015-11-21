class CreateAffiliations < ActiveRecord::Migration
  def change
    create_table :affiliations do |t|
      t.references :experience, index: true
      t.integer :user_id
      t.integer :action_type, null: false, limit: 1
      t.timestamps
    end
  end
end
