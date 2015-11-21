class AddColumnToExperience < ActiveRecord::Migration
  def change
    add_column :experiences, :advertiser_id, :integer, after: :id
    add_index  :experiences, [:advertiser_id]
  end
end
