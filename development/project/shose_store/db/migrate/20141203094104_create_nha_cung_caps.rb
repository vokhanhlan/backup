class CreateNhaCungCaps < ActiveRecord::Migration
  def change
    create_table :nha_cung_caps do |t|
      t.string :ten
      t.string :dia_chi
      t.string :email
      t.string :so_dien_thoai
      t.timestamps
    end
  end
end
