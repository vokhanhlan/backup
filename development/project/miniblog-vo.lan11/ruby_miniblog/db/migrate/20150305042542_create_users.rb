class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username,     limit: 40,  null: false, unique: true
      t.string :password,     limit: 150, null: false
      t.string :first_name,   limit: 50,  null: false
      t.string :last_name,    limit: 50,  null: false
      t.boolean :gender,      default: 1
      t.string :permission,   limit: 5,   default: '11000'
      t.string :email,        limit: 60,  null: false, unique: true
      t.string :display_name, limit: 50
      t.string :birthday,     limit: 10,  null: false
      t.string :address,      limit: 50
      t.boolean :status,      default: 0

      t.timestamps null: false
    end
  end
end
