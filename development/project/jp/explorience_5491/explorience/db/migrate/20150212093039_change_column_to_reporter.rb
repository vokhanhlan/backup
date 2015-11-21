class ChangeColumnToReporter < ActiveRecord::Migration
  def up
    change_column :reporters, :email, :string, default:"", null: false
  end

  def down
    change_column :reporters, :email, :string, null: false
  end
end
