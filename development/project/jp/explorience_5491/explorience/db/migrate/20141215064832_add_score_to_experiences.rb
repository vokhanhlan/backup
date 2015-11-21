class AddScoreToExperiences < ActiveRecord::Migration
  def change
    add_column :experiences, :score, :integer, after: :price, default: 0
  end
end
