class AddReadToFollow < ActiveRecord::Migration
  def change
    add_column :follows, :read, :boolean, :default => false
  end
end
