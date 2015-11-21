class CreateExperiences < ActiveRecord::Migration
  def change
    create_table :experiences do |t|
      t.string   :title,       null: false
      t.text     :description, null: false
      t.string   :address
      t.string   :tel
      t.string   :url
      t.string   :workday
      t.datetime :start_date
      t.datetime :end_date
      t.integer  :price
      t.timestamps
    end
  end
end
