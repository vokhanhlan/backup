class ChangeProductsReleasedOn < ActiveRecord::Migration
  def up
    rename_column :products, :description, :description_at
    change_column :products, :description_at, :string
  end

  def down
    change_column :products, :description_at, :string
    rename_column :products, :description_at, :description
  end
end
