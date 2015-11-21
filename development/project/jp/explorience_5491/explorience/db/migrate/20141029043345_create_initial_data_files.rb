class CreateInitialDataFiles < ActiveRecord::Migration
  def change
    create_table :initial_data_files do |t|
      t.string :name
      t.timestamps
    end
  end
end
