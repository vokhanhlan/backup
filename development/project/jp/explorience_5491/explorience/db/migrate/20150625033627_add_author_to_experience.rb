class AddAuthorToExperience < ActiveRecord::Migration
  def change
    # Add author attributes helpful to specified curator when created experience
    # author is Id of curator user
    add_column :experiences, :author, :integer
  end
end
