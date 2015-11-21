class ChangeColumnToFollow < ActiveRecord::Migration
  def change
    rename_column :follows, :follow_user_id, :following_id
  end
end
