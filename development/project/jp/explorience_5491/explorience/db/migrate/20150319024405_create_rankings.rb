class CreateRankings < ActiveRecord::Migration
  def change
    create_table :rankings do |t|
      t.references :user, index: true
      t.integer :experience_id
      t.integer :rank
      t.boolean :locked, default: false

      t.timestamps
    end
  end
end
