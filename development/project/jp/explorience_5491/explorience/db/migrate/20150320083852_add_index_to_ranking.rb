class AddIndexToRanking < ActiveRecord::Migration
  def change
    add_index :rankings, [:experience_id]
  end
end
