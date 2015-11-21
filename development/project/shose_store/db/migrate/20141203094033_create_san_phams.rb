class CreateSanPhams < ActiveRecord::Migration
  def change
    create_table :san_phams do |t|
      t.integer :ma_loai_san_pham
      t.integer :ma_nha_cung_cap
      t.string :ten
      t.float :don_gia
      t.text :mo_ta
      t.integer :san_pham_moi 
      t.integer :trang_thai
      t.date :ngay_san_xuat
      t.timestamps
    end
  end
end
