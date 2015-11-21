class CreateScoreLogs < ActiveRecord::Migration
  def change
    create_table :score_logs do |t|
      t.references :user, index: true
      t.integer    :other_user_id
      t.integer    :scored_type, limit: 1, null: false
      t.string     :placeholder_key
      t.string     :placeholder_value
      t.timestamps
    end
  end
end
