class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :address
      # Add two column for gem bcrypt-ruby
      t.string :password_hash
      t.string :password_salt
      t.string :avatar
      t.string :avatar_path
      t.boolean :gender
      t.string :birthday
      t.timestamps null: false
    end
  end
end
