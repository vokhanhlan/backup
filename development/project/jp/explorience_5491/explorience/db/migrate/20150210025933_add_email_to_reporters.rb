class AddEmailToReporters < ActiveRecord::Migration
  def change
    add_column :reporters, :email, :string, null: false, after: :user_id
  end
end
