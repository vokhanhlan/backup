class AddScoreAndLastSigninCheckingAtColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :score, :integer, default: 0, after: :email
    add_column :users, :last_sign_in_checking_at, :datetime, after: :score
  end
end
