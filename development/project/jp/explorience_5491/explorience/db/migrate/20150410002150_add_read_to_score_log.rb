class AddReadToScoreLog < ActiveRecord::Migration
  def change
    add_column :score_logs, :read, :boolean, :default => false
  end
end
